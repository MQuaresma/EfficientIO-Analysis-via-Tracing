#!/usr/sbin/dtrace -s

#pragma D option quiet

syscall::write:entry
{
    self->entry = timestamp;
}

syscall::lseek:entry
{
    self->random_io = 1;
}

syscall::write:return
{
    r_time = (timestamp-self->entry);
    if(self->random_io == 1)
    {
        self->random_io = 0; 
        @random_write_rate = avg(arg0/r_time);
    }
    else
        @write_rate = avg(arg0/r_time);
}

syscall::read:entry
{
    self->entry = timestamp;
}

syscall::read:return
{
    r_time = (timestamp-self->entry);
    if(self->random_io == 1)
    {
        self->random_io = 0; 
        @random_read_rate = avg(arg0/r_time);
    }
    else
        @read_rate = avg(arg0/r_time);
}

dtrace:::END
{
    printf("Read rate");
    printa(@read_rate);
    printf("Write rate");
    printa(@write_rate);
    printf("Random Read rate");
    printa(@random_read_rate);
    printf("Random Write rate");
    printa(@random_write_rate)
}