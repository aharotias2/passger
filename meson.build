project('com.github.aharotias2.passger', 'vala', 'c', version: '0.0.1')

subdir('po')

dependencies = [
  dependency('gtk+-3.0')
]

sources = files(
  'src/PassGer.vala',
  'src/PassGerWidget.vala',
  'src/PassGerConfigWidget.vala',
  'src/PassGerConfig.vala',
  'src/PassGerUtils.vala',
  'src/CharType.vala'
)

executable(
  'com.github.aharotias2.passger',
  sources,
  dependencies: dependencies,
  install: true,
  install_dir: get_option('prefix') / 'bin'
)

install_data(
  'data/com.github.aharotias2.passger.desktop',
  install_dir: get_option('prefix') / 'share' / 'applications'
)
