{%- from "apache/map.jinja" import apache with context %}

include:
  - apache

{%- if salt['pillar.get']('apache:mod_jk') %}
mod_jk:
  pkg.installed:
    - name: {{ apache.mod_jk }}
    - order: 180
    - require:
      - pkg: apache

  {%- if grains['os_family']=="Debian" %}
a2enmod jk:
  cmd.run:
    - unless: ls /etc/apache2/mods-enabled/jk.load
    - order: 225
    - require:
      - pkg: mod_jk
    - watch_in:
      - module: apache-restart
  {%- endif %}

  {%- if grains['os_family']=="Suse" or salt['grains.get']('os') == 'SUSE' %}
/etc/sysconfig/apache2:
  file.replace:
    - unless: grep '^APACHE_MODULES=.*jk' /etc/sysconfig/apache2
    - pattern: '^APACHE_MODULES=(.*)"'
    - repl: 'APACHE_MODULES=\1 jk"'
  {%- endif %}

  {%- if pillar['apache']['mod_jk']['workers'] is defined %}
{{ apache.confdir }}/jk-workers.conf:
  file.managed:
    - template: jinja
    - source: {{ pillar['apache']['mod_jk']['workers_template']|default("salt://apache/files/mod_jk-workers.jinja") }}
    - order: 225
    - watch_in:
      - module: apache-restart
    - require:
      - pkg: apache
      - pkg: mod_jk

a2enconf jk-workers.conf:
  cmd.run:
    - name: a2enconf jk-workers
    - unless: test -L /etc/apache2/conf-enabled/jk-workers.conf
    - require:
      - pkg: apache
      - file: {{ apache.confdir }}/jk-workers.conf
    - watch_in:
      - module: apache-restart

  {%- else %}
a2disconf jk-workers.conf:
  cmd.run:
    - name: a2disconf jk-workers
    - onlyif: test -L /etc/apache2/conf-enabled/jk-workers.conf
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart
  {%- endif %}

  {%- if pillar['apache']['mod_jk']['loadbalancers'] is defined %}
{{ apache.confdir }}/jk-loadbalancers.conf:
  file.managed:
    - template: jinja
    - source: {{ pillar['apache']['mod_jk']['loadbalancers_template']|default("salt://apache/files/mod_jk-loadbalancers.jinja") }}
    - order: 225
    - watch_in:
      - module: apache-restart
    - require:
      - pkg: apache
      - pkg: mod_jk

a2enconf jk-loadbalancers.conf:
  cmd.run:
    - name: a2enconf jk-loadbalancers
    - unless: test -L /etc/apache2/conf-enabled/jk-loadbalancers.conf
    - require:
      - pkg: apache
      - file: {{ apache.confdir }}/jk-loadbalancers.conf
    - watch_in:
      - module: apache-restart

  {%- else %}
a2disconf jk-loadbalancers.conf:
  cmd.run:
    - name: a2disconf jk-loadbalancers
    - onlyif: test -L /etc/apache2/conf-enabled/jk-loadbalancers.conf
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-restart
  {%- endif %}
{%- endif %}
