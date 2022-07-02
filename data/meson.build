icon_sizes = ['48']

foreach i : icon_sizes
  install_data(
    'icons' / i / (meson.project_name() + '.png'),
    install_dir: get_option('datadir') / 'icons' / 'hicolor' / (i + 'x' + i) / 'apps'
  )
endforeach
