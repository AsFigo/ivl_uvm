/*
 * Copyright (c) 1999-2020 Stephen Williams (steve@icarus.com)
 *
 *    This source code is free software; you can redistribute it
 *    and/or modify it in source code form under the terms of the GNU
 *    General Public License as published by the Free Software
 *    Foundation; either version 2 of the License, or (at your option)
 *    any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program; if not, write to the Free Software
 *    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */

#include "sys_priv.h"
#include <string.h>
#include <assert.h>

typedef struct timeval timeval;
// Srini added below code
//
//
// https://stackoverflow.com/questions/669438/how-to-get-memory-usage-at-runtime-using-c
// Srini VerifWorks added 2 additional functions on top of David's code below
// getCPUTime getUSERTime
//
/*
 * Author:  David Robert Nadeau
 * Site:    http://NadeauSoftware.com/
 * License: Creative Commons Attribution 3.0 Unported License
 *          http://creativecommons.org/licenses/by/3.0/deed.en_US
 */

#if defined(_WIN32)
#include <windows.h>
#include <psapi.h>

#elif defined(__unix__) || defined(__unix) || defined(unix) || (defined(__APPLE__) && defined(__MACH__))
#include <unistd.h>
#include <sys/resource.h>

#if defined(__APPLE__) && defined(__MACH__)
#include <mach/mach.h>

#elif (defined(_AIX) || defined(__TOS__AIX__)) || (defined(__sun__) || defined(__sun) || defined(sun) && (defined(__SVR4) || defined(__svr4__)))
#include <fcntl.h>
#include <procfs.h>

#elif defined(__linux__) || defined(__linux) || defined(linux) || defined(__gnu_linux__)
#include <stdio.h>

#endif

#else
#error "Cannot define getPeakRSS( ) or getCurrentRSS( ) for an unknown OS."
#endif




#include <stdio.h>

/**
 * Returns the peak (maximum so far) resident set size (physical
 * memory use) measured in bytes, or zero if the value cannot be
 * determined on this OS.
 */
size_t getPeakRSS( )
{
#if defined(_WIN32)
    /* Windows -------------------------------------------------- */
    PROCESS_MEMORY_COUNTERS info;
    GetProcessMemoryInfo( GetCurrentProcess( ), &info, sizeof(info) );
    return (size_t)info.PeakWorkingSetSize;

#elif (defined(_AIX) || defined(__TOS__AIX__)) || (defined(__sun__) || defined(__sun) || defined(sun) && (defined(__SVR4) || defined(__svr4__)))
    /* AIX and Solaris ------------------------------------------ */
    struct psinfo psinfo;
    int fd = -1;
    if ( (fd = open( "/proc/self/psinfo", O_RDONLY )) == -1 ) {
        return (size_t)0L;      /* Can't open? */
    } 

    if ( read( fd, &psinfo, sizeof(psinfo) ) != sizeof(psinfo) )
    {
        close( fd );
        return (size_t)0L;      /* Can't read? */
    }
    close( fd );
    return (size_t)(psinfo.pr_rssize * 1024L);

#elif defined(__unix__) || defined(__unix) || defined(unix) || (defined(__APPLE__) && defined(__MACH__))
    /* BSD, Linux, and OSX -------------------------------------- */
    struct rusage rusage;
    getrusage( RUSAGE_SELF, &rusage );
#if defined(__APPLE__) && defined(__MACH__)

    return (size_t)rusage.ru_maxrss;
#else
    return (size_t)(rusage.ru_maxrss * 1024L);
#endif

#else
    /* Unknown OS ----------------------------------------------- */
    return (size_t)0L;          /* Unsupported. */
#endif
}





/**
 * Returns the current resident set size (physical memory use) measured
 * in bytes, or zero if the value cannot be determined on this OS.
 */
size_t getCurrentRSS( )
{
#if defined(_WIN32)
    /* Windows -------------------------------------------------- */
    PROCESS_MEMORY_COUNTERS info;
    GetProcessMemoryInfo( GetCurrentProcess( ), &info, sizeof(info) );
    return (size_t)info.WorkingSetSize;

#elif defined(__APPLE__) && defined(__MACH__)
    /* OSX ------------------------------------------------------ */
    struct mach_task_basic_info info;
    mach_msg_type_number_t infoCount = MACH_TASK_BASIC_INFO_COUNT;
    if ( task_info( mach_task_self( ), MACH_TASK_BASIC_INFO,
        (task_info_t)&info, &infoCount ) != KERN_SUCCESS )
        return (size_t)0L;      /* Can't access? */
    return (size_t)info.resident_size;

#elif defined(__linux__) || defined(__linux) || defined(linux) || defined(__gnu_linux__)
    /* Linux ---------------------------------------------------- */
    long rss = 0L;
    FILE* fp = NULL;
    if ( (fp = fopen( "/proc/self/statm", "r" )) == NULL )
        return (size_t)0L;      /* Can't open? */
    if ( fscanf( fp, "%*s%ld", &rss ) != 1 )
    {
        fclose( fp );
        return (size_t)0L;      /* Can't read? */
    }
    fclose( fp );
    return (size_t)rss * (size_t)sysconf( _SC_PAGESIZE);

#else
    /* AIX, BSD, Solaris, and Unknown OS ------------------------ */
    return (size_t)0L;          /* Unsupported. */
#endif
}



/**
 * Returns the CPU/Sysetm Time as timeval struct
 * or zero if the value cannot be determined on this OS.
 */
timeval getCPUTime( )
{
  #if defined(_WIN32)
    /* Windows -------------------------------------------------- */
    // Icarus TBD 
    return (timeval)(0);

  #elif (defined(_AIX) || defined(__TOS__AIX__)) || (defined(__sun__) || defined(__sun) || defined(sun) && (defined(__SVR4) || defined(__svr4__)))
    /* AIX and Solaris ------------------------------------------ */
    // Icarus TBD 
    return (timeval)(0);

  #elif defined(__unix__) || defined(__unix) || defined(unix) || (defined(__APPLE__) && defined(__MACH__))
    /* BSD, Linux, and OSX -------------------------------------- */
    struct rusage rusage;
    getrusage( RUSAGE_SELF, &rusage );
    #if defined(__APPLE__) && defined(__MACH__)
      return rusage.ru_stime;
    #else
      // Icarus TBD 
      return (timeval)(0);
    #endif

  #else
    /* Unknown OS ----------------------------------------------- */
    return (timeval)(0);          /* Unsupported. */
  #endif
}

/**
 * Returns the User Time as timeval struct
 * or zero if the value cannot be determined on this OS.
 */

timeval getUSERTime( )
{
  #if defined(_WIN32)
    /* Windows -------------------------------------------------- */
    // Icarus TBD 
    return (timeval)(0);

  #elif (defined(_AIX) || defined(__TOS__AIX__)) || (defined(__sun__) || defined(__sun) || defined(sun) && (defined(__SVR4) || defined(__svr4__)))
    /* AIX and Solaris ------------------------------------------ */
    // Icarus TBD 
    return (timeval)(0);

  #elif defined(__unix__) || defined(__unix) || defined(unix) || (defined(__APPLE__) && defined(__MACH__))
    /* BSD, Linux, and OSX -------------------------------------- */
    struct rusage rusage;
    getrusage( RUSAGE_SELF, &rusage );
    #if defined(__APPLE__) && defined(__MACH__)
      return rusage.ru_utime;
    #else
      // Icarus TBD 
      return (timeval)(0);
    #endif

  #else
    /* Unknown OS ----------------------------------------------- */
    return (timeval)(0);          /* Unsupported. */
  #endif
}

/*
int main()
{
   //using std::cout;
   // using std::endl;

   double vm, rss;

  size_t currentSize = getCurrentRSS( );
  size_t peakSize    = getPeakRSS( );
  timeval ivl_cpu_tval;
  timeval ivl_user_tval;

  ivl_cpu_tval = getCPUTime();
  ivl_user_tval = getUSERTime();

  printf ("peakSize: %lu \n", peakSize);
  printf("User Time: %ld.%06d (s)\n", ivl_user_tval.tv_sec, ivl_user_tval.tv_usec);
  printf("CPU Time: %ld.%06d (s)\n", ivl_cpu_tval.tv_sec, ivl_cpu_tval.tv_usec);

}

*/



static PLI_INT32 sys_finish_calltf(ICARUS_VPI_CONST PLI_BYTE8 *name)
{
      vpiHandle callh, argv;
      s_vpi_value val;
      int diag_msg = 1;
      int had_arg = 0;
      char * rusage_info;

      /* Get the argument list and look for the diagnostic message level. */
      callh = vpi_handle(vpiSysTfCall, 0);
      argv = vpi_iterate(vpiArgument, callh);
      if (argv) {
	    vpiHandle arg = vpi_scan(argv);
	    vpi_free_object(argv);
	    val.format = vpiIntVal;
	    vpi_get_value(arg, &val);
	    diag_msg = val.value.integer;
	    if ((diag_msg < 0) || (diag_msg > 2)) {
		  vpi_printf("WARNING: %s:%d: ", vpi_get_str(vpiFile, callh),
		             (int)vpi_get(vpiLineNo, callh));
		  vpi_printf("%s(%d) argument must be 0, 1, or 2.\n",
		             (const char*)name, (int)diag_msg);
	    }
	    had_arg = 1;
      }

      if (diag_msg == 2) {
	      size_t ivl_mem_usage;
	      size_t ivl_mem_usage_KB;
	      timeval ivl_cpu_tval;
	      timeval ivl_usr_tval;

	      ivl_cpu_tval = getCPUTime ();
	      ivl_usr_tval = getUSERTime ();
	      ivl_mem_usage = getPeakRSS ();
	      ivl_mem_usage_KB = ivl_mem_usage/1024L;

              rusage_info = "Simulation Statistics: ";
	      vpi_printf("%s Memory: %lu (KB) User Time: %ld.%06d (s) CPU Time: %ld.%06d (s) \n",
	               rusage_info,
		       ivl_mem_usage_KB,
		       ivl_usr_tval.tv_sec, ivl_usr_tval.tv_usec, 
		       ivl_cpu_tval.tv_sec, ivl_cpu_tval.tv_usec); 
      }

      if (diag_msg != 0) {
	    s_vpi_time now;
	    int units;
	    uint64_t raw_time;

	    vpi_printf("%s:%d: %s",
	               vpi_get_str(vpiFile, callh),
	               (int)vpi_get(vpiLineNo, callh),
	               (const char*)name);

	    if (had_arg) vpi_printf("(%d)", diag_msg);
	    now.type = vpiSimTime;
	    vpi_get_time(0, &now);
	    raw_time = now.high;
	    raw_time <<= 32;
	    raw_time |= now.low;
	    vpi_printf(" called at %" PRIu64, raw_time);

	    units = vpi_get(vpiTimePrecision, 0);
	    switch (units) {
		case   2: vpi_printf(" (100s)\n");  break;
		case   1: vpi_printf(" (10s)\n");   break;
		case   0: vpi_printf(" (1s)\n");    break;
		case  -1: vpi_printf(" (100ms)\n"); break;
		case  -2: vpi_printf(" (10ms)\n");  break;
		case  -3: vpi_printf(" (1ms)\n");   break;
		case  -4: vpi_printf(" (100us)\n"); break;
		case  -5: vpi_printf(" (10us)\n");  break;
		case  -6: vpi_printf(" (1us)\n");   break;
		case  -7: vpi_printf(" (100ns)\n"); break;
		case  -8: vpi_printf(" (10ns)\n");  break;
		case  -9: vpi_printf(" (1ns)\n");   break;
		case -10: vpi_printf(" (100ps)\n"); break;
		case -11: vpi_printf(" (10ps)\n");  break;
		case -12: vpi_printf(" (1ps)\n");   break;
		case -13: vpi_printf(" (100fs)\n"); break;
		case -14: vpi_printf(" (10fs)\n");  break;
		case -15: vpi_printf(" (1fs)\n");   break;
		default:
		  vpi_printf("unknown time unit '%d'", units);
		  assert(0);
	    }
      }

      if (strcmp((const char*)name, "$stop") == 0) {
	    vpi_control(vpiStop, diag_msg);
	    return 0;
      }

      vpip_set_return_value(0);

      vpi_control(vpiFinish, diag_msg);
      return 0;
}

void sys_finish_register(void)
{
      s_vpi_systf_data tf_data;
      vpiHandle res;

      tf_data.type      = vpiSysTask;
      tf_data.tfname    = "$finish";
      tf_data.calltf    = sys_finish_calltf;
      tf_data.compiletf = sys_one_opt_numeric_arg_compiletf;
      tf_data.sizetf    = 0;
      tf_data.user_data = "$finish";
      res = vpi_register_systf(&tf_data);
      vpip_make_systf_system_defined(res);

      tf_data.type      = vpiSysTask;
      tf_data.tfname    = "$stop";
      tf_data.calltf    = sys_finish_calltf;
      tf_data.compiletf = sys_one_opt_numeric_arg_compiletf;
      tf_data.sizetf    = 0;
      tf_data.user_data = "$stop";
      res = vpi_register_systf(&tf_data);
      vpip_make_systf_system_defined(res);
}

