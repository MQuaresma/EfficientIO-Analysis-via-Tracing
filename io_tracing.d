#!/usr/sbin/dtrace -s

#pragma D option quiet

syscall::write:entry
{
    self->entry = timestamp;
}

syscall::write:return
{
    r_time = (timestamp-self->entry);
    @write_rate = avg(arg0/r_time);
}

syscall::read:entry
{
    self->entry = timestamp;
}

syscall::read:return
{
    r_time = (timestamp-self->entry);
    @read_rate = avg(arg0/r_time);
}

dtrace:::END
{
    normalize(@read_rate, 1000000000);
    normalize(@write_rate, 1000000000);
}