class Skill < ApplicationRecord
  enum enum_skill_id: { skill_windows: 1, skill_linux: 2, skill_java: 3,
                   skill_php: 4, skill_ruby: 5, skill_c: 6, skill_c_sharp: 7,
                   skill_python: 8, skill_sql: 9, skill_html: 10,
                   skill_html5: 11, skill_css: 12, skill_css3: 13,
                   skill_javascript: 14, skill_jquery: 15, skill_node: 16,
                   skill_vue: 17, skill_actionscript: 18, skill_rails: 19,
                   skill_spring: 20, skill_boot: 21, skill_struts: 22,
                   skill_thymeleaf: 23, skill_oracle: 24, skill_mysql: 25,
                   skill_postgres: 26, skill_eclipse: 27, skill_intellij: 28,
                   skill_cloud9: 29, skill_visual: 30, skill_os_other: 95,
                   skill_lang_other: 96, skill_fw_other: 97, skill_db_other: 98,
                   skill_tool_other: 99, skill_other: 100 }
end
