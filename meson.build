project(
    'nsh',
    'c',
    version: '0.0.1',
    meson_version: '>= 1.12.0',
    default_options: ['warning_level=0'],
)

fs = import('fs')

cc = meson.get_compiler('c')

m_dep = cc.find_library('m', required: true)
dep_rt = cc.find_library('rt', required: false)
dep_dl = cc.find_library('dl', required: false)

dep_curses = dependency('curses', method: 'system', required: true)

dep_libpcre = dependency('libpcre2-8', required: get_option('pcre'))
dep_libcap = dependency('libcap', required: get_option('cap'))
dep_libgdbm = dependency('libgdbm', required: get_option('gdbm'))
dep_libnsl = dependency('libnsl', required: get_option('nsl'))
dep_libiconv = dependency('iconv', required: get_option('iconv'))

dependencies = [
    m_dep,
    dep_rt,
    dep_dl,
    dep_curses,
    dep_libpcre,
    dep_libcap,
    dep_libgdbm,
    dep_libnsl,
    dep_libiconv,
]

# find external programs required to configure the project
awk = find_program('awk', required: true)
sh = find_program('sh', required: true)
sed = find_program('sed', required: true)
yodl = find_program('yodl', required: false)
getconf_bin = find_program('getconf', required: false)

# placeholder file that we will use with configure_file
placeholder_template_file = files('build-aux/placeholder.in')[0]


# data to be dumped to config.h
config_h_data = configuration_data()

# enable all debugging if build type is debug
if get_option('buildtype') == 'debug'
    config_h_data.set('DEBUG', 1)
    config_h_data.set('ZSH_MEM_DEBUG', 1)
    config_h_data.set('ZSH_MEM_WARNING', 1)
    config_h_data.set('ZSH_HEAP_DEBUG', 1)
    config_h_data.set('ZSH_HASH_DEBUG', 1)
endif

config_h_data.set('USE_SUSPENDED', get_option('use_suspended'))
config_h_data.set('DEFAULT_HISTSIZE', get_option('default_histsize'))
config_h_data.set_quoted('DEFAULT_FCEDIT', get_option('default_fcedit'))
config_h_data.set_quoted('DEFAULT_TMPPREFIX', get_option('default_tmpprefix'))
config_h_data.set('CONFIG_LOCALE', get_option('locale').enabled())

config_h_data.set_quoted('MACHTYPE', host_machine.cpu())
config_h_data.set_quoted('VENDOR', host_machine.cpu_family())
config_h_data.set_quoted('OSTYPE', host_machine.system())

etcdir = get_option('etcdir')

# list of global scripts
nsh_scripts = ['nshenv', 'nshrc', 'nprofile', 'nlogin', 'nlogout']
if etcdir == 'no'
    nsh_scripts = []
elif not fs.is_absolute(etcdir)
    error('etcdir has to be an absolute path')
endif

foreach script_name : nsh_scripts
    script_path = get_option(script_name)

    if script_path == 'no'
        continue
    endif

    if script_path == 'auto'
        script_path = script_name
    endif

    # change first n to z such that nlogin would produce GLOBAL_ZLOGIN and so on
    macro_name = 'GLOBAL_Z' + script_name.to_upper().substring(1)
    if fs.is_absolute(script_path)
        config_h_data.set_quoted(macro_name, script_path)
    else
        config_h_data.set_quoted(macro_name, etcdir / script_path)
    endif
endforeach


# Assumptions based on your autoconf context
tzsh_name = meson.project_name()
version = meson.project_version()

# Fetch built-in Meson directories
prefix = get_option('prefix')
datadir = prefix / get_option('datadir')
libdir = prefix / get_option('libdir')

moddir = libdir / tzsh_name / version

# runhelpdir & runhelp logic
runhelpdir_opt_val = get_option('runhelpdir')
if runhelpdir_opt_val == 'auto'
    runhelpdir = datadir / tzsh_name / version / 'help'
    #   runhelp = 'runhelp'
elif runhelpdir_opt_val == 'no' or runhelpdir_opt_val.strip() == ''
    runhelpdir = ''
    #   runhelp = ''
else
    runhelpdir = runhelpdir_opt_val
    #   runhelp = 'runhelp'
endif

# fndir logic
fndir_opt_val = get_option('fndir')
if fndir_opt_val == 'auto'
    fndir = datadir / tzsh_name / version / 'functions'
else
    fndir = fndir_opt_val
endif

# sitefndir & fixed_sitefndir logic
sitefndir_opt_val = get_option('site_fndir')
if sitefndir_opt_val == 'auto'
    sitefndir = datadir / tzsh_name / 'site-functions'
else
    sitefndir = sitefndir_opt_val
endif

fixed_sitefndir = ''
if sitefndir != '/usr/local/share/nsh/site-functions' and sitefndir != 'no' and sitefndir != ''
    if prefix != '/usr/local' or tzsh_name != 'nsh'
        fixed_sitefndir = '/usr/local/share/nsh/site-functions'
    endif
endif

# function-subdirs logic
if get_option('function_subdirs')
    FUNCTIONS_SUBDIRS = 'yes'
else
    FUNCTIONS_SUBDIRS = 'no'
endif

# additional-fpath logic
additionalfpath = get_option('additional_fpath')

# scriptdir & sitescriptdir logic
scriptdir_opt = get_option('scriptdir')
if scriptdir_opt == 'auto' or scriptdir_opt == 'yes'
    scriptdir = datadir / tzsh_name / version / 'scripts'
else
    scriptdir = scriptdir_opt
endif

sitescriptdir_opt = get_option('site-scriptdir')
if sitescriptdir_opt == 'auto' or sitescriptdir_opt == 'yes'
    sitescriptdir = datadir / tzsh_name / 'scripts'
else
    sitescriptdir = sitescriptdir_opt
endif

if get_option('custom-patchlevel').strip() != ''
    config_h_data.set_quoted(
        'CUSTOM_PATCHLEVEL',
        get_option('custom-patchlevel').strip(),
    )
endif

if get_option('maildir_support').enabled()
    config_h_data.set('MAILDIR_SUPPORT', 1)
endif

config_h_data.set('MAX_FUNCTION_DEPTH', get_option('max_function_depth'))
config_h_data.set_quoted(
    'DEFAULT_READNULLCMD',
    get_option('default_readnullcmd'),
)

# Multi-byte support is always enabled
# don't enable unicode9 support
config_h_data.set('MULTIBYTE_SUPPORT', 1)

# we don't support these features (at least yet)
# musl-libc
# static user lookup
# zsh mem support

# the compiler has to support the following flags
# TODO: remove code to deal with the absense of these features
assert(
    cc.sizeof('long') >= 8,
    'Error: We require "long" type to be at least 64-bit.',
)
config_h_data.set('LONG_IS_64_BIT', 1)
config_h_data.set('PRINTF_HAS_LLD', 1)
config_h_data.set('HAVE_UNION_INIT', 1)
config_h_data.set('HAVE_VARIABLE_LENGTH_ARRAYS', false)
config_h_data.set('TGETENT_ACCEPTS_NULL', 1)
config_h_data.set('TGETENT_SUCCESS', 1)
config_h_data.set('GETPGRP_VOID', 1)
config_h_data.set('ZSH_HAVE_TERM_H', 1)
config_h_data.set('ZSH_HAVE_CURSES_H', 1)
config_h_data.set('HAVE_BOOLCODES', 1)
config_h_data.set('HAVE_NUMCODES', 1)
config_h_data.set('HAVE_STRCODES', 1)
config_h_data.set('HAVE_BOOLNAMES', 1)
config_h_data.set('HAVE_NUMNAMES', 1)
config_h_data.set('HAVE_STRNAMES', 1)
config_h_data.set('RLIM_T_IS_UNSIGNED', 1)  # TODO: this is not true for FreeBSD and dragonflyBSD
config_h_data.set('RU_MAXRSS_IS_IN_BYTES', host_machine.system() == 'darwin')  # ru_maxrss is in bytes (not kb) on MacOS
config_h_data.set('USE_GETCWD', 1)
config_h_data.set('HAVE_BRK_PROTO', 1)
config_h_data.set('HAVE_SBRK_PROTO', 1)
config_h_data.set('HAVE_MKNOD_PROTO', 1)
config_h_data.set('HAVE_IOCTL_PROTO', 1)
config_h_data.set('USE_LSEEK', 1)
config_h_data.set('HAVE_LINK', 1)
config_h_data.set('DYNAMIC', 1)
config_h_data.set('DYNAMIC_NAME_CLASH_OK', 1)
config_h_data.set_quoted('DL_EXT', 'so')
config_h_data.set('ZSOCKLEN_T', 'socklen_t')
config_h_data.set('ICONV_CONST', '')

if cc.has_define('TIOCGWINSZ', prefix: '#include <sys/ioctl.h>')
    config_h_data.set('GWINSZ_IN_SYS_IOCTL', 1)
endif

if cc.has_function('ioctl', prefix: '#include <sys/ioctl.h>')
    config_h_data.set('IOCTL_IN_SYS_IOCTL', 1)
endif

# check presense of the following headers
headers_to_check = [
    'bind/netdb.h',
    'curses.h',
    'dirent.h',
    'dl.h',
    'dlfcn.h',
    'errno.h',
    'fcntl.h',
    'gdbm.h',
    'grp.h',
    'iconv.h',
    'inttypes.h',
    'langinfo.h',
    'libc.h',
    'limits.h',
    'locale.h',
    'memory.h',
    'ncurses.h',
    'ncurses/ncurses.h',
    'ncurses/term.h',
    'ncursesw/ncurses.h',
    'ncursesw/term.h',
    'ndir.h',
    'netinet/in_systm.h',
    'pcre2.h',
    'poll.h',
    'pwd.h',
    'stdarg.h',
    'stddef.h',
    'stdint.h',
    'stdio.h',
    'stdlib.h',
    'string.h',
    'strings.h',
    'sys/capability.h',
    'sys/dir.h',
    'sys/filio.h',
    'sys/mman.h',
    'sys/ndir.h',
    'sys/param.h',
    'sys/random.h',
    'sys/resource.h',
    'sys/select.h',
    'sys/stat.h',
    'sys/stropts.h',
    'sys/sysctl.h',
    'sys/time.h',
    'sys/times.h',
    'sys/types.h',
    'sys/utsname.h',
    'sys/wait.h',
    'sys/xattr.h',
    'term.h',
    'termcap.h',
    'termio.h',
    'termios.h',
    'unistd.h',
    'utmp.h',
    'utmpx.h',
    'varargs.h',
    'wchar.h',
]

foreach hdr : headers_to_check
    macro_name = 'HAVE_' + hdr.replace('/', '_').replace('.', '_').to_upper()
    if cc.check_header(
        hdr,
        prefix: '#define PCRE2_CODE_UNIT_WIDTH 8',
        dependencies: dependencies,
    )
        config_h_data.set(macro_name, 1)
    else
        config_h_data.set(macro_name, false)
    endif
endforeach

# check presence of the following functions
functions_to_check = [
    '_mktemp',
    'arc4random_buf',
    'brk',
    'canonicalize_file_name',
    'cap_get_proc',
    'clock_gettime',
    'cygwin_conv_path',
    'difftime',
    'dlclose',
    'dlerror',
    'dlopen',
    'dlsym',
    'endutxent',
    'erand48',
    'faccessx',
    'fchdir',
    'fchmod',
    'fchown',
    'fseeko',
    'fstat',
    'ftello',
    'ftruncate',
    'getcchar',
    'getcwd',
    'getenv',
    'getgrgid',
    'getgrnam',
    'gethostbyname2',
    'gethostname',
    'getipnodebyname',
    'getlogin',
    'getpgrp',
    'getpwent',
    'getpwnam',
    'getpwuid',
    'getrandom',
    'getrlimit',
    'getrusage',
    'gettimeofday',
    'getutent',
    'getutxent',
    'getxattr',
    'grantpt',
    'htons',
    'iconv',
    'inet_aton',
    'inet_ntop',
    'inet_pton',
    'initgroups',
    'initscr',
    'isblank',
    'isinf',
    'isnan',
    'iswblank',
    'killpg',
    'lchown',
    'load',
    'loadbind',
    'loadquery',
    'log2',
    'lstat',
    'memccpy',
    'memcpy',
    'memmove',
    'mkfifo',
    'mkstemp',
    'mktime',
    'mmap',
    'msync',
    'munmap',
    'nanosleep',
    'nice',
    'nl_langinfo',
    'ntohs',
    'open_memstream',
    'pathconf',
    'pcre2_compile_8',
    'poll',
    'posix_openpt',
    'prctl',
    'ptsname',
    'putenv',
    'readlink',
    'realpath',
    'regcomp',
    'regerror',
    'regexec',
    'regfree',
    'resize_term',
    'sbrk',
    'scalbn',
    'select',
    'setcchar',
    'setegid',
    'setenv',
    'seteuid',
    'setgid',
    'setlocale',
    'setpgid',
    'setpgrp',
    'setproctitle',
    'setregid',
    'setresgid',
    'setresuid',
    'setreuid',
    'setsid',
    'setuid',
    'setupterm',
    'setutxent',
    'shl_findsym',
    'shl_load',
    'shl_unload',
    'signgam',
    'sigqueue',
    'srand_deterministic',
    'strcoll',
    'strerror',
    'strftime',
    'strptime',
    'strstr',
    'strtoul',
    'symlink',
    'sysconf',
    'tcgetattr',
    'tcsetpgrp',
    'tgamma',
    'tgetent',
    'tigetflag',
    'tigetnum',
    'tigetstr',
    'timelocal',
    'uname',
    'unload',
    'unlockpt',
    'unsetenv',
    'use_default_colors',
    'waddwstr',
    'wait3',
    'waitpid',
    'wctomb',
    'wget_wch',
    'win_wch',
]

foreach func : functions_to_check
    macro_name = 'HAVE_' + func.to_upper()
    if cc.has_function(func, dependencies: dependencies)
        config_h_data.set(macro_name, 1)
    else
        config_h_data.set(macro_name, false)
    endif
endforeach

# check if iconv() is linked from libiconv
iconv_code = '''
  #include <iconv.h>
  int main(void) {
      int myversion = _libiconv_version;
      return 0;
  }
  '''

if cc.links(iconv_code, dependencies: dep_libiconv)
    config_h_data.set('ICONV_FROM_LIBICONV', 1)
endif

# check whether the following structs have specified members
struct_members_to_check = [
    {
        'struct_name': 'stat',
        'prefix': '#include <sys/stat.h>',
        'members': [
            'st_atim.tv_nsec',
            'st_atimespec.tv_nsec',
            'st_atimensec',
            'st_mtim.tv_nsec',
            'st_mtimespec.tv_nsec',
            'st_mtimensec',
            'st_ctim.tv_nsec',
            'st_ctimespec.tv_nsec',
            'st_ctimensec',
        ],
    },
    {
        'struct_name': 'rusage',
        'prefix': '#include <sys/types.h>\n#include <sys/time.h>\n#include <sys/resource.h>',
        'members': [
            'ru_maxrss',
            'ru_ixrss',
            'ru_idrss',
            'ru_isrss',
            'ru_minflt',
            'ru_majflt',
            'ru_nswap',
            'ru_inblock',
            'ru_oublock',
            'ru_msgsnd',
            'ru_msgrcv',
            'ru_nsignals',
            'ru_nvcsw',
            'ru_nivcsw',
        ],
    },
    {
        'struct_name': 'dirent',
        'prefix': '#include <dirent.h>',
        'members': ['d_ino', 'd_stat'],
    },
    {
        'struct_name': 'utmp',
        'prefix': '#include <utmp.h>',
        'members': ['ut_host'],
    },
    {
        'struct_name': 'utmpx',
        'prefix': '#include <utmpx.h>',
        'members': ['ut_host', 'ut_xtime', 'ut_tv'],
    },
    {
        'struct_name': 'sockaddr_in6',
        'prefix': '#include <sys/types.h>\n#include <netinet/in.h>',
        'members': ['sin6_scope_id'],
    },
]

foreach struct : struct_members_to_check
    foreach member : struct['members']
        macro_name = 'HAVE_STRUCT_' + struct['struct_name'].to_upper() + '_' + member.to_upper().replace(
            '.',
            '_',
        )
        struct_member_found = cc.has_member(
            'struct ' + struct['struct_name'],
            member,
            prefix: struct['prefix'],
        )

        if struct_member_found
            config_h_data.set(macro_name, 1)
        else
            config_h_data.set(macro_name, false)
        endif
    endforeach
endforeach

config_h_data.set(
    'HAVE_STRUCT_TIMEZONE',
    cc.has_type('struct timezone', prefix: '#include <sys/time.h>'),
)
config_h_data.set(
    'HAVE_STRUCT_TIMESPEC',
    cc.has_type('struct timespec', prefix: '#include <sys/time.h>'),
)
config_h_data.set(
    'HAVE_STRUCT_UTMP',
    cc.has_type('struct utmp', prefix: '#include <utmp.h>'),
)
config_h_data.set(
    'HAVE_STRUCT_UTMPX',
    cc.has_type('struct utmpx', prefix: '#include <utmpx.h>'),
)

config_h_data.set10(
    'HAVE_DECL_FPURGE',
    cc.has_header_symbol('stdio.h', 'fpurge'),
)

# check if the following macros are defined
macros_to_check = [
    'RLIMIT_AIO_MEM',
    'RLIMIT_AIO_OPS',
    'RLIMIT_AS',
    'RLIMIT_LOCKS',
    'RLIMIT_MEMLOCK',
    'RLIMIT_NPROC',
    'RLIMIT_NTHR',
    'RLIMIT_NOFILE',
    'RLIMIT_PTHREAD',
    'RLIMIT_THREADS',
    'RLIMIT_RSS',
    'RLIMIT_SBSIZE',
    'RLIMIT_TCACHE',
    'RLIMIT_VMEM',
    'RLIMIT_SIGPENDING',
    'RLIMIT_MSGQUEUE',
    'RLIMIT_NICE',
    'RLIMIT_RTPRIO',
    'RLIMIT_RTTIME',
    'RLIMIT_POSIXLOCKS',
    'RLIMIT_NPTS',
    'RLIMIT_SWAP',
    'RLIMIT_KQUEUES',
    'RLIMIT_UMTXP',
    'RLIMIT_PIPEBUF',
    'RLIMIT_NOVMON',
]

foreach macro : macros_to_check
    config_h_data.set(
        'HAVE_' + macro.to_upper(),
        cc.has_define(
            macro,
            prefix: '#include <sys/types.h>\n#include <sys/time.h>\n#include <sys/resource.h>',
        ),
    )
endforeach

# check rlimit
rlimit_equal_pairs = [
    ['VMEM', 'vmem', 'RSS', 'rss'],
    ['VMEM', 'vmem', 'AS', 'as'],
    ['RSS', 'rss', 'AS', 'as'],
]

foreach pair : rlimit_equal_pairs
    rlim1 = pair[0]
    rlim2 = pair[1]
    rlim3 = pair[2]
    rlim4 = pair[3]

    # Construct the compile check code block dynamically
    check_code = '''
    int main(void) {
        static char x[(RLIMIT_@0@ == RLIMIT_@1@) ? 1 : -1];
        (void)x;
        return 0;
    }
    '''.format(rlim1, rlim3)

    config_h_data.set(
        'RLIMIT_@0@_IS_@1@'.format(rlim1, rlim3),
        cc.compiles(check_code),
    )
endforeach

realpath_accepts_null_code = '''
#include <stdlib.h>
#include <limits.h>

int main(void) {
    return(!realpath("/", (char*)0));
}
'''

config_h_data.set(
    'REALPATH_ACCEPTS_NULL',
    cc.run(realpath_accepts_null_code).returncode() == 0,
)

linux_xattr_code = '''
  #include <stddef.h>
  #include <sys/types.h>
  #include <sys/xattr.h>
  int main(void) {
      (void)listxattr("", NULL, 0);
      (void)getxattr("", "", NULL, 0);
      (void)setxattr("", "", NULL, 0, 0);
      (void)removexattr("", "");
      return 0;
  }
  '''

is_linux_xattr = cc.compiles(linux_xattr_code)

if not is_linux_xattr
    mac_xattr_code = '''
    #include <stddef.h>
    #include <sys/types.h>
    #include <sys/xattr.h>
    int main(void) {
        (void)listxattr("", NULL, 0, 0);
        (void)getxattr("", "", NULL, 0, 0, 0);
        (void)setxattr("", "", NULL, 0, 0, 0);
        (void)removexattr("", "", 0);
        return 0;
    }
    '''

    is_mac_xattr = cc.compiles(mac_xattr_code)

    if is_mac_xattr
        config_h_data.set('XATTR_EXTRA_ARGS', 1)
    endif
endif

getcwd_calls_malloc_code = '''
#include <unistd.h>
#include <string.h>
int main() {
    char buf[1024], *ptr1, *ptr2;
    ptr1 = getcwd(buf, 1024);
    ptr2 = getcwd(NULL, 0);
    if (ptr1 && ptr2 && !strcmp(ptr1, ptr2)) {
      return 0;
    }
    return 1;
}
'''

config_h_data.set(
    'GETCWD_CALLS_MALLOC',
    cc.run(getcwd_calls_malloc_code).returncode() == 0,
)

# determine default path variable
default_path = '/bin:/usr/bin'

if getconf_bin.found()
    getconf_keys = ['_CS_PATH', 'CS_PATH', 'PATH']

    foreach key : getconf_keys
        res = run_command(getconf_bin, key, check: false)

        if res.returncode() == 0
            default_path = res.stdout().strip()
            break
        endif
    endforeach
endif

config_h_data.set_quoted('DEFAULT_PATH', default_path)

foreach p : ['/proc/self/fd', '/dev/fd']
    if run_command(sh, '-c', 'exec 3<&0 && [ -r ' + p + '/3 ]', check: false).returncode() == 0
        config_h_data.set_quoted('PATH_DEV_FD', p)
        break
    endif
endforeach

paths = [
    '/proc/self/exe',
    '/proc/curproc/exe',
    '/proc/curproc/file',
    '/proc/self/path/a.out',
]

foreach p : paths
    if run_command(sh, '-c', '[ -L ' + p + ' ]', check: false).returncode() == 0
        config_h_data.set_quoted('PROC_SELF_EXE', p)
        break
    endif
endforeach

# The directories to search, mirroring your M4 macro
utmp_search_dirs = [
    '/etc',
    '/usr/etc',
    '/var/adm',
    '/usr/adm',
    '/var/run',
    '/var/log',
]

utmp_file_check = [['utmp'], ['wtmp'], ['utmpx', 'utx.active'], ['wtmpx']]

foreach utmp_file : utmp_file_check
    foreach utmp_dir : utmp_search_dirs
        # Slice the array from index 1 onward to get all file variants
        foreach utmp_file_variant : utmp_file
            potential_path = utmp_dir / utmp_file_variant
            if fs.exists(potential_path) and not fs.is_dir(potential_path)
                config_h_data.set_quoted(
                    'PATH_' + utmp_file[0].to_upper() + '_FILE',
                    potential_path,
                )
                break
            endif
        endforeach
    endforeach
endforeach

# TODO: change $$ with PID or non-unique value
fifo_test_code = '''
#include <fcntl.h>
#include <signal.h>
#include <unistd.h>
#include <sys/stat.h>
int main()
{
    char c;
    int fd;
    int pid, ret;
    unlink("/tmp/fifo$$");
#ifdef HAVE_MKFIFO
    if(mkfifo("/tmp/fifo$$", 0600) < 0)
#else
    if(mknod("/tmp/fifo$$", 0010600, 0) < 0)
#endif
	return(1);
    pid = fork();
    if(pid < 0)
	return(1);
    if(pid) {
	fd = open("/tmp/fifo$$", O_RDONLY);
	return(fd < 0 || read(fd, &c, 1) != 1 || c != 'x');
    }
    fd = open("/tmp/fifo$$", O_WRONLY);
    ret = (fd < 0 || write(fd, "x", 1) < 1);
    unlink("/tmp/fifo$$");
    return(ret);
}
'''
config_h_data.set('HAVE_FIFOS', cc.run(fifo_test_code).returncode() == 0)

if fs.exists('/dev/ptmx') and config_h_data.get('HAVE_POSIX_OPENPT') == 1 and config_h_data.get(
    'HAVE_GRANTPT',
) == 1 and config_h_data.get(
    'HAVE_UNLOCKPT',
) == 1 and config_h_data.get(
    'HAVE_PTSNAME',
) == 1
    ptmx_usable_code = '''
    #if defined(__linux) || defined(__CYGWIN__)
#define _GNU_SOURCE 1
#endif
#include <stdlib.h>
int ptsname();
    '''

    config_h_data.set('USE_DEV_PTMX', not cc.compiles(ptmx_usable_code))
endif

isprint_broken_code = '''
char *my_locales[] = { "en_US.UTF-8", "en_GB.UTF-8", "en.UTF-8", 0 };
#include <locale.h>
#include <ctype.h>

int main() {
  char **localep;
  for (localep = my_locales; *localep; localep++)
    if (setlocale(LC_ALL, *localep) && isprint(0xa0))
      return 0;
  return 1;
}
'''
config_h_data.set(
    'BROKEN_ISPRINT',
    cc.run(isprint_broken_code).returncode() == 0,
)

# output the config.h file
configure_file(output: 'config.h', configuration: config_h_data)

if host_machine.system() == 'cygwin'
    MOD_EXPORT = '__attribute__((__dllexport__))'
    MOD_IMPORT_VARIABLE = '__attribute__((__dllimport__))'
    MOD_IMPORT_FUNCTION = ''
else
    MOD_EXPORT = ''
    MOD_IMPORT_VARIABLE = ''
    MOD_IMPORT_FUNCTION = ''
endif

subdir('Completion')
subdir('Functions')
subdir('Scripts')
subdir('Src')
subdir('Doc')
subdir('Test')

summary(module_link_type_map)
