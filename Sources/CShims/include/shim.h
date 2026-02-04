#ifndef SHIM_H
#define SHIM_H

// POSIX
#include <pthread.h>
#include <semaphore.h>
#include <signal.h>
#include <sys/time.h>
#include <unistd.h>

// Mach
#include <mach/mach.h>
#include <mach/task.h>
#include <mach/thread_act.h>
#include <mach/mach_time.h>

#endif
