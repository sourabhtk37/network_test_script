[servers]
${test_ip}
${dut_ip}
# DO NOT CHANGE ANYTHING BELOW THIS LINE
[servers:vars]
cenv = ec2
# where to get the key
pbench_key_url = http://git.app.eng.bos.redhat.com/git/perf-dept.git/plain/bench/pbench/agent/{{ pbench_configuration_environment }}/ssh

# where to get the config file
pbench_config_url = http://git.app.eng.bos.redhat.com/git/perf-dept.git/plain/bench/pbench/agent/{{ pbench_configuration_environment }}/config
