{% import 'project/_vars.sls' as vars with context %}

include:
  - supervisor.pip
  - project.dirs
  - project.venv
  - postfix

default_conf:
  file.managed:
    - name: /etc/supervisor/conf.d/{{ pillar['project_name'] }}-celery-default.conf
    - source: salt://project/worker/celery.conf
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - context:
        log_dir: "{{ vars.log_dir }}"
        settings: "{{ pillar['project_name'] }}.settings.deploy"
        virtualenv_root: "{{ vars.venv_dir }}"
        directory: "{{ vars.source_dir }}"
        name: "celery-default"
        use_newrelic: {{ vars.use_newrelic }}
        command: "worker"
        flags: "--loglevel=INFO"
    - require:
      - pip: supervisor
      - file: log_dir
      - pip: pip_requirements
    - watch_in:
      - cmd: supervisor_update

default_process:
  supervisord.running:
    - name: {{ pillar['project_name'] }}-celery-default
    - restart: True
    - require:
      - file: default_conf
