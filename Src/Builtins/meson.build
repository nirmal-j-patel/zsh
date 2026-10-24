modules_to_compile += {
    'zsh/rlimits': {
        'link': 'either',
        'load': true,
        'functions': [],
        'headers': [],
        'sources': files('rlimits.c'),
        'autofeatures': ['b:limit', 'b:ulimit', 'b:unlimit'],
        'autofeatures_emu': ['b:ulimit'],
        'moddeps': [],
    },
    'zsh/sched': {
        'link': 'either',
        'load': true,
        'functions': [],
        'headers': [],
        'sources': files('sched.c'),
        'autofeatures': ['b:sched', 'p:zsh_scheduled_events'],
        'autofeatures_emu': [],
        'moddeps': [],
    },
}
