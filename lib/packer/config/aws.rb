require 'securerandom'

module Packer
  module Config
    class Aws < Base
      def initialize(aws_access_key, aws_secret_key, regions)
        @aws_access_key = aws_access_key
        @aws_secret_key = aws_secret_key
        @regions = regions
      end

      def builders
        builders = []
        @regions.each do |region|
          builders.push(
            'name' => "amazon-ebs-#{region['name']}",
            'type' => 'amazon-ebs',
            'access_key' => @aws_access_key,
            'secret_key' => @aws_secret_key,
            'region' => region['name'],
            'source_ami' => region['base_ami'],
            'instance_type' => 'm4.xlarge',
            'ami_name' => "BOSH-#{SecureRandom.uuid}-#{region['name']}",
            'vpc_id' => region['vpc_id'],
            'subnet_id' => region['subnet_id'],
            'associate_public_ip_address' => true,
            'communicator' => 'winrm',
            'winrm_username' => 'Administrator',
            'user_data_file' => 'scripts/aws/setup_winrm.txt',
            'security_group_id' => region['security_group'],
            'ami_groups' => 'all'
          )
        end
        builders
      end

      def provisioners
        [
          Provisioners::AGENT_ZIP,
          Provisioners::AGENT_DEPS_ZIP,
          Provisioners::INSTALL_WINDOWS_FEATURES,
          Provisioners::SETUP_AGENT,
          Provisioners::AWS_AGENT_CONFIG,
          Provisioners::CLEANUP_WINDOWS_FEATURES,
          Provisioners::SET_EC2_PASSWORD,
          Provisioners::DISABLE_SERVICES,
          Provisioners::SET_FIREWALL,
          Provisioners::CLEANUP_ARTIFACTS
        ]
      end
    end
  end
end