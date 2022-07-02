project('com.github.aharotias2.passger', 'vala', 'c', version: '0.0.1')

subdir('po')

add_project_arguments(
  [
    '--vapidir', join_paths(meson.current_source_dir()),
    '--pkg', 'config'
  ],
  language: 'vala'
)

config_h = configuration_data()
config_h.set_quoted('VERSION', meson.project_version())
config_h.set_quoted('APP_ID', meson.project_name())
config_h.set_quoted('DATADIR', get_option('prefix') / get_option('datadir'))

config_file = configure_file(
  output: 'config.h',
  configuration: config_h
)

project_config_dep = declare_dependency(
  sources: config_file,
  include_directories: include_directories('.')
)

executable(
  meson.project_name(),
  'src/PassGer.vala',
  'src/PassGerWidget.vala',
  'src/PassGerConfigWidget.vala',
  'src/PassGerConfig.vala',
  'src/PassGerUtils.vala',
  'src/PassGerMath.vala',
  'src/CharType.vala',
  dependencies: [
    dependency('gtk+-3.0'),
    project_config_dep
  ],
  install: true,
  install_dir: get_option('prefix') / 'bin'
)

install_data(
  'data' / '@0@.desktop'.format(meson.project_name()),
  install_dir: get_option('prefix') / 'share' / 'applications'
)

subdir('data')
