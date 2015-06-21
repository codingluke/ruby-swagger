require 'spec_helper'

require 'rake'
load "#{File.dirname(__FILE__)}/../../lib/tasks/swagger.rake"
require_relative 'grape/application_api'


describe 'Ruby::Swagger' do

  def no_stdout
    $stdout = StringIO.new
  end

  def open_yaml(file)
    YAML::load_file(file)
  end

  before do
    FileUtils.rm_rf("./doc/swagger")
  end

  after do
    FileUtils.rm_rf("./doc/swagger")
  end

  describe 'rake swagger:grape:generate_doc' do

    let(:rake_task) { Rake::Task['swagger:grape:generate_doc'] }

    before do
      rake_task.reenable
      no_stdout
      rake_task.invoke('ApplicationsAPI')
    end

    it 'should generate a base_doc.yaml' do
      expect(File.exists?("./doc/swagger/base_doc.yaml")).to be_truthy
    end

    it 'base_doc.yaml contains valid information' do
      base_doc = open_yaml "./doc/swagger/base_doc.yaml"
      expect(base_doc['swagger']).to eq '2.0'
      expect(base_doc['info']['title']).to eq 'My uber-duper API'
      expect(base_doc['info']['description']).to eq 'My uber-duper API description'
      expect(base_doc['info']['termsOfService']).to eq 'https://localhost/tos.html'

      expect(base_doc['info']['contact']['name']).to eq 'John Doe'
      expect(base_doc['info']['contact']['email']).to eq 'john.doe@example.com'
      expect(base_doc['info']['contact']['url']).to eq 'https://google.com/?q=john%20doe'

      expect(base_doc['info']['license']['name']).to eq 'Apache 2.0'
      expect(base_doc['info']['license']['url']).to eq 'http://www.apache.org/licenses/LICENSE-2.0.html'

      expect(base_doc['info']['version']).to eq '0.1'

      expect(base_doc['host']).to eq 'localhost:80'
      expect(base_doc['basePath']).to eq '/api/v1'
      expect(base_doc['schemes']).to eq ['https', 'http']
      expect(base_doc['consumes']).to eq ['application/json']
      expect(base_doc['produces']).to eq ['application/json']
    end

    it 'should generate a paths folder' do
      expect(Dir.exists?('./doc/swagger/paths')).to be_truthy
    end

    it 'should generate a ./doc/swagger/paths/applications/get.yaml file' do
      expect(File.exists?('./doc/swagger/paths/applications/get.yaml')).to be_truthy
    end

    # the endpoint is hidden - nothing to see here
    it 'should NOT generate a ./doc/swagger/paths/applications/{id}/get.yaml file' do
      expect(File.exists?('./doc/swagger/paths/applications/{id}/get.yaml')).to be_falsey
    end

    it 'should generate a ./doc/swagger/paths/applications/{id}/post.yaml file' do
      expect(File.exists?('./doc/swagger/paths/applications/{id}/post.yaml')).to be_truthy
    end

    it 'should generate a ./doc/swagger/paths/applications/{id}/delete.yaml file' do
      expect(File.exists?('./doc/swagger/paths/applications/{id}/delete.yaml')).to be_truthy
    end

    it 'should generate a ./doc/swagger/paths/applications/{id}/check_access/get.yaml file' do
      expect(File.exists?('./doc/swagger/paths/applications/{id}/check_access/get.yaml')).to be_truthy
    end

    describe 'deprecation' do
      it 'should include information about deprecation in applications/get.yaml' do
        expect(open_yaml('./doc/swagger/paths/applications/get.yaml')['deprecated']).to be_truthy
      end
    end

    describe 'tags' do
      it 'should include tags information in applications/get.yaml' do
        expect(open_yaml('./doc/swagger/paths/applications/get.yaml')['tags']).to eq(['applications'])
      end

      it 'should include tags information in applications/{id}/check_access/get.yaml' do
        expect(open_yaml('./doc/swagger/paths/applications/{id}/check_access/get.yaml')['tags']).to eq(['applications', 'getter'])
      end

      it 'should include tags information in applications/{id}/post.yaml' do
        expect(open_yaml('./doc/swagger/paths/applications/{id}/post.yaml')['tags']).to eq(['applications', 'create', 'swag'])
      end
    end

    describe 'documentation description' do

      it 'should include a summary and a detail in applications/get.yaml' do
        expect(open_yaml('./doc/swagger/paths/applications/get.yaml')['summary']).to eq "Retrieves applications list"
        expect(open_yaml('./doc/swagger/paths/applications/get.yaml')['description']).to eq 'This API does this and that and more'
      end

      it 'should include a summary and a detail in applications/{id}/post.yaml' do
        expect(open_yaml('./doc/swagger/paths/applications/{id}/post.yaml')['summary']).to eq "Install / buy the application by its unique id or by its code name."
        expect(open_yaml('./doc/swagger/paths/applications/{id}/post.yaml')['description']).to eq "Install / buy the application by its unique id or by its code name."
      end

      it 'should include a summary and a detail in applications/{id}/delete.yaml' do
        expect(open_yaml('./doc/swagger/paths/applications/{id}/delete.yaml')['summary']).to eq "Uninstall / unsubscribe an application by its unique id or by its code name."
        expect(open_yaml('./doc/swagger/paths/applications/{id}/delete.yaml')['description']).to eq "Uninstall / unsubscribe an application by its unique id or by its code name."
      end

    end

    describe 'operationId' do
      it 'should include an operationId in applications/get.yaml' do
        expect(open_yaml('./doc/swagger/paths/applications/get.yaml')['operationId']).to eq "get_applications"
      end
    end

    describe 'params' do
      it 'should get parameters for applications/get.yaml' do
        doc = open_yaml('./doc/swagger/paths/applications/get.yaml')

        expect(doc['parameters'].count).to eq 4

        expect(doc['parameters'][0]['name']).to eq 'Authorization'
        expect(doc['parameters'][0]['in']).to eq 'header'
        expect(doc['parameters'][0]['description']).to eq 'A valid user session token, in the format \'Bearer TOKEN\''
        expect(doc['parameters'][0]['type']).to eq 'string'
        expect(doc['parameters'][0]['required']).to eq true

        expect(doc['parameters'][1]['name']).to eq 'limit'
        expect(doc['parameters'][1]['in']).to eq 'formData'
        expect(doc['parameters'][1]['description']).to eq 'Number of profiles returned. Default is 30 elements, max is 100 elements per page.'
        expect(doc['parameters'][1]['type']).to eq 'integer'

        expect(doc['parameters'][2]['name']).to eq 'offset'
        expect(doc['parameters'][2]['in']).to eq 'formData'
        expect(doc['parameters'][2]['description']).to eq 'Offset for pagination result. Use it combined with the limit field. Default is 0.'
        expect(doc['parameters'][2]['type']).to eq 'integer'

        expect(doc['parameters'][3]['name']).to eq 'q[service]'
        expect(doc['parameters'][3]['in']).to eq 'formData'
        expect(doc['parameters'][3]['description']).to eq 'Filter by application exposing a given service'
        expect(doc['parameters'][3]['type']).to eq 'string'
      end

      it 'should get parameters for applications/{id}/delete.yaml' do
        doc = open_yaml('./doc/swagger/paths/applications/{id}/delete.yaml')

        expect(doc['parameters'].count).to eq 1

        expect(doc['parameters'][0]['name']).to eq 'id'
        expect(doc['parameters'][0]['in']).to eq 'path'
        expect(doc['parameters'][0]['description']).to be_nil
        expect(doc['parameters'][0]['type']).to eq 'string'
        expect(doc['parameters'][0]['required']).to be_truthy
      end

    end


  end


end