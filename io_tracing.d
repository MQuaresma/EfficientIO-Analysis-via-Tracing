#!/usr/sbin/dtrace -s

#pragma D option quiet

dtrace:::BEGIN
/execname == "iozone"/
{
    read_delta = 0;
    reread_delta = 0;
    random_read_delta = 0;
    write_delta = 0;
    rewrite_delta = 0;
    random_write_delta = 0;
}

syscall::open:entry
/execname == "iozone"/
{
    if(!(arg1 & O_CREAT)) //file already exists
    {
        self->exists = 1;
    }
}

syscall::close:return
/execname == "iozone"/
{
    self->exists = 0;
}


syscall::read:entry,
syscall::write:entry
/execname == "iozone"/
{
    self->entry = timestamp;
}

//initiate non continuous IO op
syscall::lseek:return
/execname == "iozone"/
{
    self->random_io = 1;
}

syscall::write:return
/execname == "iozone" && self->entry/
{
    r_time = (timestamp-self->entry);
    if(self->exists)
    {
        rewrite_delta += r_time;
        @rewrite_rate = sum(arg0);
    }
    else if(self->random_io == 1)
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
/execname == "iozone" && self->entry/
{
    r_time = (timestamp-self->entry);
    if(self->exists)
    {
        reread_delta += r_time;
        @reread_rate = sum(arg0);
    }
    else if(self->random_io == 1)
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
/execname == "iozone"/
{
    this->seconds = read_delta / 1000000000;
    printf("Read rate:");
    normalize(@read_rate, this->seconds);
    printa(@read_rate);

    this->seconds = reread_delta / 1000000000;
    printf("Reread rate:");
    normalize(@reread_rate, this->seconds);
    printa(@reread_rate);

    this->seconds = random_read_delta / 1000000000;
    printf("Random Read rate:");
    normalize(@random_read_rate, this->seconds);
    printa(@random_read_rate);

    // Writes
    this->seconds = write_delta / 1000000000;
    printf("Write rate:");
    normalize(@write_rate, this->seconds);
    printa(@write_rate);

    this->seconds = rewrite_delta / 1000000000;
    printf("Rewrite rate:");
    normalize(@rewrite_rate, this->seconds);
    printa(@rewrite_rate);

    this->seconds = random_write_delta / 1000000000;
    printf("Random Write rate:");
    normalize(@random_write_rate, this->seconds);
    printa(@random_write_rate);
}
