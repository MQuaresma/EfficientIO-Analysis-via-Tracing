#!/usr/sbin/dtrace -s

#pragma D option quiet

dtrace:::BEGIN
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
    if(arg1 & O_CREAT) //file already exists
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
{
    printf("Read\n");
    printf("Read time (ns): \n\t%d\nAmount (bytes):", read_delta);
    printa(@read_rate);

    printf("Reread\n");
    printf("Reread time (ns): \n\t%d\nAmount (bytes):", reread_delta);
    printa(@reread_rate);

    printf("Random Read\n");
    printf("Random Read time (ns): \n\t%d\nAmount (bytes):", random_read_delta);
    printa(@random_read_rate);

    // Writes
    printf("Write\n");
    printf("Write time (ns): \n\t%d\nAmount (bytes):", write_delta);
    printa(@write_rate);

    printf("Rewrite\n");
    printf("Rewrite time (ns): \n\t%d\nAmount (bytes):", rewrite_delta);
    printa(@rewrite_rate);

    printf("Random Write\n");
    printf("Random Write time (ns): \n\t%d\nAmount (bytes):", random_write_delta);
    printa(@random_write_rate);
}
