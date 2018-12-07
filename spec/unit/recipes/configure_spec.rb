require 'spec_helper'

describe 'pgbouncer-service::configure' do

  context 'When all attributes are default, on an Ubuntu 16.04' do
    let(:environment) { 'staging' }
    let(:user) { 'foo' }
    let(:password) { 'bar' }

    let(:chef_run) do
      ChefSpec::ServerRunner.new(platform: 'ubuntu', version: '16.04') do |node, server|
        server.create_environment(environment)
        node.pgbouncer_add_user(user, password, admin: true, stats: true)
        node.chef_environment = environment
      end
    end

    context 'converges' do
      it 'does so successfully' do
        expect { chef_run.converge(described_recipe) }.to_not raise_error
      end

      it 'should have the user' do
        expect { chef_run.converge(described_recipe) }.to_not raise_error
        expect(chef_run.node['pgbouncer']['stats_users']).to eq(['foo'])
        expect(chef_run.node['pgbouncer']['admin_users']).to eq(['foo'])
      end

    end

  end
end
