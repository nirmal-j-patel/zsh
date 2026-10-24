# list of modules to compile
modules_to_compile = {}

# list of dynamic module targets
nsh_dynamic_modules = []

# list of static module targets to be compiled to main shell
nsh_static_module_dependencies = []

# { mod_name : { 'mdh': ..., 'epro': ..., 'pro': ..., }
generated_headers = {}

# include subdirectories and populate modules_to_compile
subdir('Builtins')
subdir('Modules')
subdir('Zle')

# identify the list of dynamically linked and statically linked modules
module_link_type_map = {'zsh/main': 'static'}

foreach mod_name, mod_info : modules_to_compile
    default_link = get_option('default_module_type')
    dynamic_modules_disabled = get_option('dynamic_modules').disabled()

    module_link_option_name = 'module_link_type_' + mod_name.split('/')[-1]
    module_link_option_value = get_option(module_link_option_name)

    if module_link_option_value == 'disabled' or module_link_option_value == 'static' or module_link_option_value == 'dynamic'
        link_type = module_link_option_value
    elif module_link_option_value == 'auto'
        if mod_info['link'] == 'either'
            link_type = default_link
        else
            link_type = mod_info['link']
        endif
    endif

    if link_type == 'dynamic' and dynamic_modules_disabled
        link_type = 'disabled'
    endif

    module_link_type_map += {mod_name: link_type}
endforeach


inc_dir = include_directories('.', '..', 'Zle')

###################################
# Files needed for zsh/main module
###################################
version_h = configure_file(
    output: 'version.h',
    configuration: {'ZSH_VERSION': '"' + meson.project_version() + '"'},
)

git_patchlevel = run_command(
    'git',
    'describe',
    '--always',
    '--tags',
    capture: true,
    check: false,
).stdout().strip()
patchlevel_h = configure_file(
    output: 'patchlevel.h',
    configuration: {'ZSH_PATCHLEVEL': '"' + git_patchlevel + '"'},
)

curses_header = 'curses.h'
if cc.has_header('ncurses.h')
    curses_header = 'ncurses.h'
endif

nshcurses_h = configure_file(
    input: placeholder_template_file,
    output: 'zshcurses.h',
    configuration: {
        'CONTENT': f'#include <@curses_header@>',
    },
)

nshterm_h = configure_file(
    input: placeholder_template_file,
    output: 'zshterm.h',
    configuration: {
        'CONTENT': '#include <term.h>',
    },
)

nsh_paths_config = configuration_data()
nsh_paths_config.set_quoted('MODULE_DIR', moddir)

if sitescriptdir != 'no' and sitescriptdir != ''
    nsh_paths_config.set_quoted('SITESCRIPT_DIR', sitescriptdir)
endif

if scriptdir != 'no' and scriptdir != ''
    nsh_paths_config.set_quoted('SCRIPT_DIR', scriptdir)
endif

if sitefndir != 'no' and sitefndir != ''
    nsh_paths_config.set_quoted('SITEFPATH_DIR', sitefndir)
endif

if fixed_sitefndir != ''
    nsh_paths_config.set_quoted('FIXED_FPATH_DIR', fixed_sitefndir)
endif

if fndir != ''
    nsh_paths_config.set_quoted('FPATH_DIR', fndir)
endif

if additionalfpath != ''
    fpath_formatted = '{ "' + additionalfpath.replace(',', '", "') + '" }'
    nsh_paths_config.set_quoted('ADDITIONAL_FPATH', fpath_formatted)
endif

nshpaths_h = configure_file(
    output: 'zshpaths.h',
    configuration: nsh_paths_config,
)

signames_c = custom_target(
    'signames.c',
    output: 'signames.c',
    command: [
        sh,
        meson.project_source_root() / 'build-aux' / 'generate_sig_headers.sh',
    ],
    # depend_files: files('../build-aux/generate_sig_headers.sh'),
    env: {
        'CPP': cc.cmd_array(),
        'CPPFLAGS': '-E',
        'sdir': meson.project_source_root() / 'Src',
    },
    capture: true,
)

sigcount_h = custom_target(
    'sigcount.h',
    input: signames_c,
    output: 'sigcount.h',
    command: ['grep', 'define.*SIGCOUNT', signames_c],
    capture: true,
)

zshxmods_h_contents = ''
foreach mod_name, mod : modules_to_compile
    escaped_mod_name = mod_name.replace('Q', 'Qq').replace('_', 'Qu').replace(
        '/',
        'Qs',
    )

    if module_link_type_map[mod_name] == 'static'
        # if escaped_mod_name != 'zshQsmain'
        zshxmods_h_contents += '#define LINKED_XMOD_@0@ 1\n'.format(
            escaped_mod_name,
        )
        # endif
    elif module_link_type_map[mod_name] == 'dynamic'
        zshxmods_h_contents += f'''
#ifdef DYNAMIC
# define UNLINKED_XMOD_@escaped_mod_name@ 1
#endif
'''
    endif
endforeach

configure_file(
    input: placeholder_template_file,
    output: 'zshxmods.h',
    configuration: {
        'CONTENT': zshxmods_h_contents,
    },
)

main_shell_generated_headers = [
    version_h,
    patchlevel_h,
    nshcurses_h,
    nshterm_h,
    nshpaths_h,
    sigcount_h,
    # bltinmods_list,
    # zshxmods_h,
]

modules_to_compile += {
    'zsh/main': {
        'name': 'zsh/main',
        'link': 'static',
        'load': true,
        # 'builddir': 'Src',
        'functions': zsh_functions,
        'headers': [
            'config.h',
            'zsh_system.h',
            'zsh.h',
            'sigcount.h',
            'signals.h',
            'prototypes.h',
            'hashtable.h',
            'ztype.h',
        ],
        'sources': files(
            'builtin.c',
            'compat.c',
            'cond.c',
            'context.c',
            'exec.c',
            'glob.c',
            'hashnameddir.c',
            'hashtable.c',
            'hist.c',
            'init.c',
            'input.c',
            'jobs.c',
            'lex.c',
            'linklist.c',
            'loop.c',
            'main.c',
            'math.c',
            'mem.c',
            'modentry.c',
            'module.c',
            'openssh_bsd_setres_id.c',
            'options.c',
            'params.c',
            'parse.c',
            'pattern.c',
            'prompt.c',
            'signals.c',
            'sort.c',
            'string.c',
            'subst.c',
            'text.c',
            'utils.c',
        ) + main_shell_generated_headers + signames_c,
        'autofeatures': [],
        'autofeatures_emu': [],
        'moddeps': [],
    },
}


############################
# Create bltinmods.list file
############################
bltinmods_list_contents = ''

# bltinmods.list: autoloaded modules
foreach mod_name, mod : modules_to_compile
    # mod_name = mod['name']

    if mod['load'] and module_link_type_map[mod_name] != 'disabled'
        if module_link_type_map[mod_name] == 'static'
            bltinmods_list_contents += f'/* linked-in known module `@mod_name@\' */\n'
        else
            bltinmods_list_contents += f'''#ifdef DYNAMIC
/* non-linked-in known module `@mod_name@' */
'''
        endif

        autofeature_joined = '"' + '",\n      "'.join(mod['autofeatures']) + '",'
        autofeature_emu_joined = '"' + '",\n      "'.join(
            mod['autofeatures_emu'],
        ) + '",'

        if mod['autofeatures'].length() > 0
            if mod['autofeatures_emu'].length() > 0
                bltinmods_list_contents += f'''  {
    char *zsh_features[] = { 
      @autofeature_joined@
      NULL
    }; 
    char *emu_features[] = { 
      @autofeature_emu_joined@
      NULL
    }; 
    autofeatures("zsh", "@mod_name@",
       EMULATION(EMULATE_ZSH) ? zsh_features : emu_features,
       0, 1);
  }
'''
            else
                bltinmods_list_contents += f'''  if (EMULATION(EMULATE_ZSH)) {
    char *features[] = { 
      @autofeature_joined@
      NULL
    }; 
    autofeatures("zsh", "@mod_name@", features, 0, 1);
  }
'''
            endif
        endif

        foreach dep : mod['moddeps']
            bltinmods_list_contents += f'  add_dep("@mod_name@", "@dep@");\n'
        endforeach

        if module_link_type_map[mod_name] != 'static'
            bltinmods_list_contents += '#endif\n'
        endif
    endif
endforeach

# bltinmods.list: dynamically linked modules that are not loaded
foreach mod_name, mod : modules_to_compile
    if module_link_type_map[mod_name] == 'dynamic' and not mod['load'] and mod['moddeps'].length() > 0
        bltinmods_list_contents += f'''
#ifdef DYNAMIC
/* non-linked-in known module `@mod_name@' */
'''
        foreach dep : mod['moddeps']
            bltinmods_list_contents += f'  add_dep("@mod_name@", "@dep@");\n'
        endforeach
        bltinmods_list_contents += '#endif\n'
    endif
endforeach

# bltinmods.list: statically linked modules
foreach mod_name, mod : modules_to_compile
    # mod_name = mod['name']

    if module_link_type_map[mod_name] == 'static'
        escaped_mod_name = mod_name.replace('Q', 'Qq').replace('_', 'Qu').replace(
            '/',
            'Qs',
        )
        bltinmods_list_contents += f'''/* linked-in module `@mod_name@' */
    {
        extern int setup_@escaped_mod_name@ (Module);
        extern int boot_@escaped_mod_name@ (Module);
        extern int features_@escaped_mod_name@ (Module,char***);
        extern int enables_@escaped_mod_name@ (Module,int**);
        extern int cleanup_@escaped_mod_name@ (Module);
        extern int finish_@escaped_mod_name@ (Module);

        register_module("@mod_name@",
                        setup_@escaped_mod_name@,
                        features_@escaped_mod_name@,
                        enables_@escaped_mod_name@,
                        boot_@escaped_mod_name@,
                        cleanup_@escaped_mod_name@, finish_@escaped_mod_name@);
    }'''
    endif
endforeach

configure_file(
    input: placeholder_template_file,
    output: 'bltinmods.list',
    configuration: {
        'CONTENT': bltinmods_list_contents,
    },
)

######################################
# Create .mdh file and compile modules
######################################
foreach mod_name, mod : modules_to_compile
    # generated_headers = []

    # come up with out mdh file name by using mdh_name property or inferring based on module name
    guessed_mdh_file_name = mod_name.split('/')[-1]
    if (guessed_mdh_file_name == 'main')
        guessed_mdh_file_name = 'zsh'
    endif
    guessed_mdh_file_name += '.mdh'

    mdh_file_name = mod.get('mdh_name', guessed_mdh_file_name)

    escaped_mod_name = mod_name.replace('Q', 'Qq').replace('_', 'Qu').replace(
        '/',
        'Qs',
    )

    mdh_contents = f'''#ifndef have_@escaped_mod_name@_module
#define have_@escaped_mod_name@_module

# ifndef IMPORTING_MODULE_@escaped_mod_name@
#  ifndef MODULE
#   define boot_ boot_@escaped_mod_name@
#   define cleanup_ cleanup_@escaped_mod_name@
#   define features_ features_@escaped_mod_name@
#   define enables_ enables_@escaped_mod_name@
#   define setup_ setup_@escaped_mod_name@
#   define finish_ finish_@escaped_mod_name@
#  endif /* !MODULE */
# endif /* !IMPORTING_MODULE_@escaped_mod_name@ */
'''

    if mod_name != 'zsh/main'
        mdh_contents += '''
/* Module dependencies */
'''
    endif

    foreach moddephdr : mod['moddeps']
        mdh_contents += '# define IMPORTING_MODULE_' + moddephdr.replace(
            'Q',
            'Qq',
        ).replace(
            '_',
            'Qu',
        ).replace(
            '/',
            'Qs',
        ) + ' 1\n'
        mdh_contents += '# include "' + moddephdr.split('/')[-1] + '.mdh"\n'
    endforeach

    mdh_contents += '''# define IMPORTING_MODULE_zshQsmain 1
# include "zsh.mdh"
'''

    if mod['headers'].length() > 0
        mdh_contents += '''
/* Extra headers for this module */
'''
    endif
    foreach hdr : mod['headers']
        mdh_contents += '# include "' + hdr + '"\n'
    endforeach

    mdh_contents += f'''
# undef mod_import_variable
# undef mod_import_function
# if defined(IMPORTING_MODULE_@escaped_mod_name@) &&  defined(MODULE)
#  define mod_import_variable @MOD_IMPORT_VARIABLE@
#  define mod_import_function @MOD_IMPORT_FUNCTION@
# else
#  define mod_import_function
#  define mod_import_variable
# endif /* IMPORTING_MODULE_@escaped_mod_name@ && MODULE */
'''

    current_mod_pro_headers = []
    current_mod_epro_headers = []
    foreach source_file : mod['sources']
        if fs.suffix(source_file) == '.c'
            epro_name = fs.stem(source_file) + '.epro'
            pro_name = fs.stem(source_file) + '.pro'
            sym_name = fs.stem(source_file) + '.sym'
            mdh_contents += '# include "' + epro_name + '"\n'

            sym_target = custom_target(
                sym_name,
                output: sym_name,
                command: [
                    awk,
                    '-f',
                    files('makepro.awk'),
                    source_file,
                    'Src',
                ],
                input: [files('makepro.awk'), source_file],
                capture: true,
                build_subdir: 'sym',
            )

            epro_target = custom_target(
                epro_name,
                input: sym_target,
                output: epro_name,
                command: [sed, '-n', '/^E/{s/^E//;p;}', '@INPUT@'],
                capture: true,
                build_subdir: 'epro',
            )

            pro_target = custom_target(
                pro_name,
                input: sym_target,
                output: pro_name,
                command: [sed, '-n', '/^L/{s/^L//;p;}', '@INPUT@'],
                capture: true,
                build_subdir: 'pro',
            )

            current_mod_pro_headers += pro_target
            current_mod_epro_headers += epro_target
        endif
    endforeach

    mdh_contents += f'''# undef mod_import_variable
# define mod_import_variable
# undef mod_import_variable
# define mod_import_variable
# ifndef mod_export
#  define mod_export @MOD_EXPORT@
# endif /* mod_export */

'''

    mdh_contents += f'#endif /* !have_@escaped_mod_name@_module */'


    configure_file(
        input: placeholder_template_file,
        output: mdh_file_name,
        configuration: {
            'CONTENT': mdh_contents,
        },
    )

    generated_headers += {
        mod_name: current_mod_pro_headers + current_mod_epro_headers,
    }
endforeach

libnsh_static = []
foreach mod_name, mod : modules_to_compile
    target_name = mod_name.split('/')[-1]

    # # all plugins depend on main zsh headers
    required_generated_headers = main_shell_generated_headers
    required_generated_headers += generated_headers['zsh/main']
    required_generated_headers += generated_headers[mod_name]

    if module_link_type_map[mod_name] == 'static'
        libnsh_static += static_library(
            target_name,
            mod['sources'] + required_generated_headers,
            include_directories: inc_dir,
            dependencies: dependencies,
        )
    elif module_link_type_map[mod_name] == 'dynamic'
        # required_generated_headers += generated_headers[mod_name]['mdh'] + generated_headers[mod_name]['epro'] + generated_headers[mod_name]['pro']
        nsh_dynamic_modules += shared_module(
            target_name,
            mod['sources'] + required_generated_headers,
            name_prefix: '',
            c_args: '-DMODULE',
            include_directories: inc_dir,
            dependencies: dependencies,
            build_subdir: 'Modules/' + fs.parent(mod_name),
            install: true,
            install_dir: moddir / fs.parent(mod_name),
        )
    endif

    if mod.get('functions', []).length() > 0
        install_data(mod['functions'], install_dir: fndir)
    endif

    if mod.get('scripts', []).length() > 0
        install_data(mod['scripts'], install_dir: scriptdir)
    endif
endforeach

nsh_exe = executable(
    'nsh',
    link_whole: libnsh_static,
    export_dynamic: true,
    install: true,
)

nsh_exe_for_tests_only = executable(
    'zsh',
    link_whole: libnsh_static,
    install: false,
    export_dynamic: true,
)

