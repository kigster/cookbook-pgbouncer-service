require 'spec_helper'

describe 'pgbouncer-service::default' do
  before do
    allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('pgbouncer-service::install_from_source')
    allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('pgbouncer-service::configure')
  end

  context 'When all attributes are default, on an Ubuntu 16.04' do
    let(:environment) { 'staging' }
    let(:user) { 'foo' }
    let(:password) { 'bar' }

    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04') do |node, server|
        server.create_environment(environment)
        node.chef_environment = environment
      end
    end

    context 'converges' do
      it 'does so successfully' do
        expect { chef_run.converge(described_recipe) }.to_not raise_error
        expect(chef_run.node['pgbouncer']['stats_users']).to eq([])
      end
    end

  end
end
