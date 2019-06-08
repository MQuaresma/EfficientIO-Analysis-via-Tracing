#!/usr/sbin/dtrace -s

#pragma D option quiet

dtrace:::BEGIN
{
    read_delta = 0;
    random_read_delta = 0;
    write_delta = 0;
    random_write_delta = 0;
}


syscall::read:entry,
syscall::write:entry
{
    self->entry = timestamp;
}

//initiate non continuous IO op
syscall::lseek:return
{
    self->random_io = 1;
}

syscall::write:return
/self->entry/
{
    r_time = (timestamp-self->entry);
    if(self->random_io == 1)
    {
        self->random_io = 0;
        random_write_delta += r_time;
        @random_write_rate = sum(arg0);
    }
    else
    {
        write_delta += r_time;
        @write_rate = sum(arg0);
    }
}

syscall::read:return
/self->entry/
{
    r_time = (timestamp-self->entry);
    if(self->random_io == 1)
    {
        self->random_io = 0;
        random_read_delta += r_time;
        @random_read_rate = sum(arg0);
    }
    else
    {
        read_delta += r_time;
        @read_rate = sum(arg0);
    }
}

dtrace:::END
{
    normalize(@read_rate, read_delta/1000000000);
    normalize(@write_rate, write_delta/1000000000);
    normalize(@random_read_rate, random_read_delta/1000000000);
    normalize(@random_write_rate, random_write_delta/1000000000);
}
