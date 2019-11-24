require 'model/project_build'
require 'date'

module ObjectFactory
  def create_project_build(params = {})
    default_params = {
        :name => 'FAKEPROJ-MYPROJ',
        :activity => :sleeping,
        :last_build_status => :success,
        :last_build_label => '39',
        :last_build_time => DateTime.parse('2010-01-17T17:39:35Z'),
        :next_build_time => nil,
        :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-39'
    }

    ProjectBuild.new(default_params.merge(params))
  end

  def create_bamboo_rest_result(params)
    default_params = {
        :last_build_status => :success,
        :last_build_label => '39',
        :last_build_time => 'Sun, 17 Jan 2010 17:39:35 GMT',
        :web_url => 'http://fakeproj.org/bamboo/browse/FAKEPROJ-MYPROJ-39'
    }
    values = default_params.merge(params)

    %Q(
{
  "expand": "changes,metadata,plan,vcsRevisions,artifacts,comments,labels,jiraIssues,variables,stages",
  "link": {
    "href": "#{values[:web_url]}",
    "rel": "self"
  },
  "plan": {
    "shortName": "#{values[:name]}",
    "shortKey": "SCDF17X",
    "type": "chain",
    "enabled": true,
    "link": {
      "href": "https://build.spring.io/rest/api/latest/plan/SCD-SCDF17X",
      "rel": "self"
    },
    "key": "SCD-SCDF17X",
    "name": "#{values[:name]} - #{values[:name]}",
    "planKey": {
      "key": "SCD-SCDF17X"
    }
  },
  "planName": "#{values[:name]}",
  "projectName": "#{values[:name]}",
  "buildResultKey": "SCD-SCDF17X-71",
  "lifeCycleState": "Finished",
  "id": 287493128,
  "buildStartedTime": "2019-07-02T06:10:00.189Z",
  "prettyBuildStartedTime": "Tue, 2 Jul, 06:10 AM",
  "buildCompletedTime": "#{DateTime.parse(values[:last_build_time]).strftime('%Y-%m-%dT%H:%M:%SZ')}",
  "buildCompletedDate": "#{DateTime.parse(values[:last_build_time]).strftime('%Y-%m-%dT%H:%M:%SZ')}",
  "prettyBuildCompletedTime": "#{values[:last_build_time]}",
  "buildDurationInSeconds": 686,
  "buildDuration": 686891,
  "buildDurationDescription": "11 minutes",
  "buildRelativeTime": "4 months ago",
  "vcsRevisionKey": "56e654d64f5bdf1990b753bb8ed93a4cabfb76c4",
  "vcsRevisions": {
    "size": 1,
    "start-index": 0,
    "max-result": 1
  },
  "buildTestSummary": "1340 passed",
  "successfulTestCount": 1340,
  "failedTestCount": 0,
  "quarantinedTestCount": 0,
  "skippedTestCount": 8,
  "continuable": false,
  "onceOff": false,
  "restartable": false,
  "notRunYet": false,
  "finished": true,
  "successful": #{values[:last_build_status] == :success},
  "buildReason": "Manual run by blah",
  "reasonSummary": "Manual run by blah",
  "key": "SCD-SCDF17X-#{values[:last_build_label]}",
  "planResultKey": {
    "key": "SCD-SCDF17X-#{values[:last_build_label]}",
    "entityKey": {
      "key": "SCD-SCDF17X"
    },
    "resultNumber": #{values[:last_build_label]}
  },
  "state": "#{values[:last_build_status] == :success ? 'Successful' : 'Failed'}",
  "buildState": "#{values[:last_build_status] == :success ? 'Successful' : 'Failed'}",
  "number": #{values[:last_build_label]},
  "buildNumber": #{values[:last_build_label]}
}
    )
  end
end