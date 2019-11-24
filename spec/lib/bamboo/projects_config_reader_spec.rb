require File.join(File.dirname(__FILE__), '../../spec_helper')
require 'lib/bamboo/projects_config_reader'

module Bamboo
  describe 'projects config reader' do
    before(:each) do
      @projects_config_reader = ProjectsConfigReader.new('yaml_file_path')
    end

    describe 'reading file with single Bamboo server' do
      before(:each) do
        expect(YAML).to receive(:load_file).with('yaml_file_path').and_return([
          {
            'a_bamboo_server' => {
                'url' => 'http://somedomain.com/bamboo/',
                'build_keys' => [ 'FAKEPROJ-MYPROJ1', 'FAKEPROJ-MYPROJ2' ]
            }
          }
        ])
      end

      it 'should return Bamboo build keys for multiple projects' do
        expect(@projects_config_reader.project_build_log_cxns.map { |cxn| cxn[:build_key] })
            .to eq ['FAKEPROJ-MYPROJ1', 'FAKEPROJ-MYPROJ2']
      end
    end

    describe 'reading file with multiple Bamboo servers' do
      before(:each) do
        expect(YAML).to receive(:load_file).with('yaml_file_path').and_return([
          {
            'a_bamboo_server' => { 'url' => 'http://xyz.com/builds/', 'build_keys' => [ 'FAKEPROJ-MYPROJ1' ] }
          },
          {
            'another_bamboo_server' => { 'url' => 'http://abc.com/bamboo', 'build_keys' => [ 'FAKEPROJ-MYPROJ1', 'FAKEPROJ-MYPROJ2' ] }
          }
        ])
      end

      it 'should return Bamboo RSS urls for multiple projects' do
        cxns = @projects_config_reader.project_build_log_cxns
        expect(cxns.map { |cxn| cxn[:build_key] })
            .to eq ['FAKEPROJ-MYPROJ1', 'FAKEPROJ-MYPROJ1', 'FAKEPROJ-MYPROJ2']

        expect(cxns[0][:client]).to_not eq cxns[1][:client]
      end
    end
  end
end
