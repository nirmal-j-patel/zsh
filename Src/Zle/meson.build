iwidgets = []
foreach line : fs.read('iwidgets.list').splitlines()
    if line.strip().startswith('#')
        continue
    endif

    if line.strip() == ''
        continue
    endif

    tokens = line.split(',')
    canonical_name = tokens[0].strip().strip('"')
    function_name = tokens[1].strip()
    zle_flags = tokens[2].strip()

    iwidgets += {
        'canonical_name': canonical_name,
        'function_name': function_name,
        'zle_flags': zle_flags,
    }
endforeach

# message(iwidgets)

widgets_contents = '''/** widgets.list                               **/
/** widget structures for the internal widgets **/

/* format: W(ZLE_FLAGS, t_firstname, functionname) */

'''

zle_widget_h_contents = '''/** zle_widget.h                                **/
/** indices of and pointers to internal widgets **/

enum {'''

thingies_contents = '''/** thingies.list                            **/
/** thingy structures for the known thingies **/

/* format: T("name", TH_FLAGS, w_widget, t_nextthingy) */

'''

zle_things_h_contents = '''/** zle_things.h                              **/
/** indices of and pointers to known thingies **/

enum {'''

foreach widget : iwidgets
    canonical_name = widget['canonical_name']
    function_name = widget['function_name']
    zle_flags = widget['zle_flags']

    escaped_name = widget['canonical_name'].replace('-', '')

    widgets_contents += f'W(@zle_flags@, t_@escaped_name@, @function_name@)\n'
    zle_widget_h_contents += f'''
    wi_@escaped_name@,
#define w_@escaped_name@ (&widgets[wi_@escaped_name@])'''

    thingies_contents += f'T("@canonical_name@", 0, w_@escaped_name@, t_D@escaped_name@)\n'
    zle_things_h_contents += f'''
    z_@escaped_name@,
#define t_@escaped_name@ (&thingies[z_@escaped_name@])'''
endforeach

foreach widget : iwidgets
    canonical_name = widget['canonical_name']
    escaped_name = widget['canonical_name'].replace('-', '')

    thingies_contents += f'T(".@canonical_name@", TH_IMMORTAL, w_@escaped_name@, t_@escaped_name@)\n'
    zle_things_h_contents += f'''
    z_D@escaped_name@,
#define t_D@escaped_name@ (&thingies[z_D@escaped_name@])'''
endforeach

zle_widget_h_contents += '''
    ZLE_BUILTIN_WIDGET_COUNT
};'''

zle_things_h_contents += '''
    ZLE_BUILTIN_THINGY_COUNT
};'''

configure_file(
    input: placeholder_template_file,
    output: 'widgets.list',
    configuration: {
        'CONTENT': widgets_contents,
    },
)

configure_file(
    input: placeholder_template_file,
    output: 'zle_widget.h',
    configuration: {
        'CONTENT': zle_widget_h_contents,
    },
)

configure_file(
    input: placeholder_template_file,
    output: 'thingies.list',
    configuration: {
        'CONTENT': thingies_contents,
    },
)

configure_file(
    input: placeholder_template_file,
    output: 'zle_things.h',
    configuration: {
        'CONTENT': zle_things_h_contents,
    },
)

modules_to_compile += {
    'zsh/compctl': {
        'link': 'either',
        'load': true,
        'functions': [],
        'headers': ['compctl.h'],
        'sources': files(
            'compctl.c',
        ),
        'autofeatures': ['b:compctl', 'b:compcall'],
        'autofeatures_emu': [],
        'moddeps': ['zsh/complete', 'zsh/zle'],
    },
    'zsh/complete': {
        'link': 'either',
        'load': true,
        'functions': complete_functions,
        'moddeps': ['zsh/zle'],
        'autofeatures': [
            'b:compadd',
            'b:compset',
            'c:prefix',
            'c:suffix',
            'c:between',
            'c:after',
        ],
        'autofeatures_emu': [],
        'headers': ['comp.h'],
        'sources': files(
            'complete.c',
            'compcore.c',
            'compmatch.c',
            'compresult.c',
        ),
    },
    'zsh/complist': {
        'link': 'either',
        'load': true,
        'sources': files('complist.c'),
        'autofeatures': [],
        'autofeatures_emu': [],
        'headers': [],
        'moddeps': ['zsh/complete', 'zsh/zle'],
    },
    'zsh/computil': {
        'link': 'either',
        'load': true,
        'sources': files('computil.c'),
        'autofeatures': [
            'b:compdescribe',
            'b:comparguments',
            'b:compvalues',
            'b:compquote',
            'b:comptags',
            'b:comptry',
            'b:compfiles',
            'b:compgroups',
        ],
        'autofeatures_emu': [],
        'headers': [],
        'moddeps': ['zsh/complete', 'zsh/zle'],
    },
    'zsh/deltochar': {
        'link': 'dynamic',
        'load': false,
        'moddeps': ['zsh/zle'],
        'sources': files('deltochar.c'),
        'autofeatures': [],
        'autofeatures_emu': [],
        'headers': [],
    },
    'zsh/zle': {
        # 'link': 'static',
        'link': 'either',
        # 'link': 'dynamic',
        'load': true,
        'functions': zle_functions,
        'headers': ['zle.h', 'zle_things.h'],
        'sources': files(
            'zle_bindings.c',
            'zle_hist.c',
            'zle_keymap.c',
            'zle_main.c',
            'zle_misc.c',
            'zle_move.c',
            'zle_params.c',
            'zle_refresh.c',
            'zle_thingy.c',
            'zle_tricky.c',
            'zle_utils.c',
            'zle_vi.c',
            'zle_word.c',
            'termquery.c',
            'textobjects.c',
        ),
        'autofeatures': ['b:bindkey', 'b:vared', 'b:zle'],
        'autofeatures_emu': [],
        'moddeps': [],
            # 'builddir': meson.current_build_dir()
    },
    'zsh/zleparameter': {
        'link': 'either',
        'load': true,
        'moddeps': ['zsh/zle'],
        'sources': files('zleparameter.c'),
        'autofeatures': ['p:widgets', 'p:keymaps'],
        'autofeatures_emu': [],
        'headers': [],
    },
}
