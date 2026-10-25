moddocsrc = files(
    'Zsh/mod_attr.yo',
    'Zsh/mod_cap.yo',
    'Zsh/mod_clone.yo',
    'Zsh/mod_compctl.yo',
    'Zsh/mod_complete.yo',
    'Zsh/mod_complist.yo',
    'Zsh/mod_computil.yo',
    'Zsh/mod_curses.yo',
    'Zsh/mod_datetime.yo',
    'Zsh/mod_db_gdbm.yo',
    'Zsh/mod_deltochar.yo',
    'Zsh/mod_example.yo',
    'Zsh/mod_files.yo',
    'Zsh/mod_hlgroup.yo',
    'Zsh/mod_ksh93.yo',
    'Zsh/mod_langinfo.yo',
    'Zsh/mod_mapfile.yo',
    'Zsh/mod_mathfunc.yo',
    'Zsh/mod_nearcolor.yo',
    'Zsh/mod_newuser.yo',
    'Zsh/mod_parameter.yo',
    'Zsh/mod_pcre.yo',
    'Zsh/mod_private.yo',
    'Zsh/mod_random.yo',
    'Zsh/mod_regex.yo',
    'Zsh/mod_sched.yo',
    'Zsh/mod_socket.yo',
    'Zsh/mod_stat.yo',
    'Zsh/mod_system.yo',
    'Zsh/mod_tcp.yo',
    'Zsh/mod_termcap.yo',
    'Zsh/mod_terminfo.yo',
    'Zsh/mod_watch.yo',
    'Zsh/mod_zftp.yo',
    'Zsh/mod_zle.yo',
    'Zsh/mod_zleparameter.yo',
    'Zsh/mod_zprof.yo',
    'Zsh/mod_zpty.yo',
    'Zsh/mod_zselect.yo',
    'Zsh/mod_zutil.yo',
)

man_pages = {
    'zsh.1': files(
        'Zsh/compat.yo',
        'Zsh/filelist.yo',
        'Zsh/files.yo',
        'Zsh/intro.yo',
        'Zsh/invoke.yo',
        'Zsh/metafaq.yo',
        'Zsh/seealso.yo',
    ),
    'zshbuiltins.1': files('Zsh/builtins.yo'),
    'zshcalsys.1': files('Zsh/calsys.yo'),
    'zshcompctl.1': files('Zsh/compctl.yo'),
    'zshcompwid.1': files('Zsh/compwid.yo'),
    'zshcompsys.1': files('Zsh/compsys.yo'),
    'zshcontrib.1': files('Zsh/contrib.yo'),
    'zshexpn.1': files('Zsh/expn.yo'),
    'zshmisc.1': files(
        'Zsh/arith.yo',
        'Zsh/compat.yo',
        'Zsh/cond.yo',
        'Zsh/exec.yo',
        'Zsh/func.yo',
        'Zsh/grammar.yo',
        'Zsh/jobs.yo',
        'Zsh/prompt.yo',
        'Zsh/redirect.yo',
    ),
    # 'nshmodules.1': files('Zsh/modlist.yo', 'Zsh/modmenu.yo', 'Zsh/modules.yo') + moddocsrc,
    'zshoptions.1': files('Zsh/options.yo'),
    'zshparam.1': files('Zsh/params.yo'),
    'zshroadmap.1': files('Zsh/roadmap.yo'),
    'zshtcpsys.1': files('Zsh/tcpsys.yo'),
    'zshzftpsys.1': files('Zsh/zftpsys.yo'),
    'zshzle.1': files('Zsh/zle.yo'),
}
# man_pages += {'nshall.1': man_pages['nsh.1']}

configure_file(
    input: 'version.yo.in',
    output: 'version.yo',
    configuration: {
        'VERSION': meson.project_version(),
        'VERSION_DATE': '1970-01-01',
        'NSHENV': 'WIP',
        'NPROFILE': 'WIP',
        'NSHRC': 'WIP',
        'NLOGIN': 'WIP',
        'NLOGOUT': 'WIP',
    },
)

moddoc_list = []

modlist_yo_contents = 'startitem()\n'

foreach moddocfile : moddocsrc
    moddoccontents = fs.read(moddocfile).splitlines()

    modname = moddoccontents[0].replace('COMMENT(!MOD!', '')

    moddescr = ''
    foreach line : moddoccontents.slice(1, moddoccontents.length())
        if line.startswith('!MOD!')
            break
        else
            moddescr += line + '\n'
        endif
    endforeach

    moddoc_list += modname

    modlist_yo_contents += f'''item(tt(@modname@))(
@moddescr@)
'''
endforeach

modlist_yo_contents += '''enditem()
includefile(Zsh/modmenu.yo)
'''

foreach index : range(moddocsrc.length())
    # modfile = moddocsrc[index].full_path()
    modfile = fs.relative_to(moddocsrc[index], meson.current_source_dir())

    modname = moddoc_list[index]
    prev_modname = index == 0 ? '' : 'The ' + moddoc_list[index - 1] + ' Module'
    next_modname = index < moddoc_list.length() - 1 ? 'The ' + moddoc_list[index + 1] + ' Module' : ''

    modlist_yo_contents += f'''texinode(The @modname@ Module)(@next_modname@)(@prev_modname@)(Zsh Modules)
sect(The @modname@ Module)
includefile(@modfile@)
'''
endforeach

configure_file(
    input: placeholder_template_file,
    output: 'modlist.yo',
    configuration: {
        'CONTENT': modlist_yo_contents,
    },
)


manmodmenu_yo_contents = ''
foreach moddoc : moddoc_list
    manmodmenu_yo_contents += f'menu(The @moddoc@ Module)\n'
endforeach

configure_file(
    input: placeholder_template_file,
    output: 'manmodmenu.yo',
    configuration: {
        'CONTENT': manmodmenu_yo_contents,
    },
)
configure_file(
    input: placeholder_template_file,
    output: 'modmenu.yo',
    configuration: {
        'CONTENT': 'startmenu()\n' + manmodmenu_yo_contents + 'endmenu()',
    },
)

generated_man_pages = []

if yodl.found()
    foreach manpage, yodl_sources : man_pages
        filename = fs.stem(manpage) + '.yo'

        generated_man_pages += custom_target(
            manpage,
            input: filename,
            output: '@BASENAME@.1',
            depend_files: yodl_sources,
            command: [
                yodl,
                '-k',
                '-L',
                '-o',
                '@OUTPUT@',
                '-I' + meson.current_source_dir() + ':.',
                '-w',
                'zman.yo',
                meson.current_build_dir() / 'version.yo',
                '@INPUT@',
            ],
            install: true,
            install_dir: get_option('mandir') / 'man1',
            build_by_default: true,
        )
    endforeach
endif
