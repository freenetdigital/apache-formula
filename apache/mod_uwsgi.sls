{% from "apache/map.jinja" import apache with context %}

include:
  - apache

mod_uwsgi:
  pkg.installed:
    - name: {{ apache.mod_uwsgi }}
    - require:
      - pkg: apache

{% if 'conf_mod_uwsgi' in apache %}
{{ apache.conf_mod_uwsgi }}:
  file.uncomment:
    - regex: LoadModule
    - onlyif: test -f {{ apache.conf_mod_uwsgi }}
    - require:
      - pkg: mod_uwsgi
{% endif %}
