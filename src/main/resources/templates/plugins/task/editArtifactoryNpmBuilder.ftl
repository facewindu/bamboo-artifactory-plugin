<div id="artifactory-error" class="aui-message aui-message-error error shadowed"
     style="display: none; width: 80%; font-size: 80%"></div>

[@ww.select labelKey='artifactory.task.npm.header.command.choice' name='artifactory.task.npm.command.choice' listKey='key' listValue='value' toggle='true' list=npmCommandOptions/]
[@ui.bambooSection dependsOn='artifactory.task.npm.command.choice' showOn='install']
    [@ww.textfield labelKey='artifactory.task.npm.header.install.npmArguments' name='artifactory.task.npm.install.npmArguments'/]
[/@ui.bambooSection]

[@ww.textfield labelKey='artifactory.task.npm.header.workingSubdirectory' name='artifactory.task.npm.workingSubdirectory'/]

[#assign addExecutableLink][@ui.displayAddExecutableInline executableKey='npm'/][/#assign]
[@ww.select cssClass="builderSelectWidget" labelKey='executable.type' name='artifactory.task.npm.executable'
list=uiConfigBean.getExecutableLabels('npm') extraUtility=addExecutableLink required='true'/]

[@ww.textfield labelKey='builder.common.env' name='artifactory.task.npm.environmentVariables' /]

[@ui.bambooSection dependsOn='artifactory.task.npm.command.choice' showOn='install']
    [@ww.select labelKey='artifactory.task.npm.header.resolutionArtifactoryServerId' name='artifactory.task.npm.resolutionArtifactoryServerId' list=serverConfigManager.allServerConfigs
    listKey='id' listValue='url' onchange='javascript: displayResolutionNpmArtifactoryConfigs(this.value)' emptyOption=true toggle='true'/]

    <div id="npmArtifactoryResolvingConfigDiv">
    [@ww.select labelKey='artifactory.task.npm.header.resolutionRepo' name='artifactory.task.npm.resolutionRepo' list=dummyList
    listKey='repoKey' listValue='repoKey' toggle='true'/]

    [@ww.textfield labelKey='artifactory.task.npm.header.resolverUsername' name='artifactory.task.npm.resolverUsername'/]

    [@ww.password labelKey='artifactory.task.npm.header.resolverPassword' name='artifactory.task.npm.resolverPassword' showPassword='true'/]
    [#--The Dummy password is a workaround for the autofill (Chrome)--]
    [@ww.password name='artifactory.password.DUMMY' cssStyle='visibility:hidden; position: absolute'/]
    </div>
[/@ui.bambooSection]


[@ui.bambooSection dependsOn='artifactory.task.npm.command.choice' showOn='pack and publish']
    [@ww.select labelKey='artifactory.task.npm.header.artifactoryServerId' name='artifactory.task.npm.artifactoryServerId' list=serverConfigManager.allServerConfigs
    listKey='id' listValue='url' onchange='javascript: displayPublishingNpmArtifactoryConfigs(this.value)' emptyOption=true toggle='true'/]

    <div id="npmArtifactoryPublishingConfigDiv">
    [@ww.select labelKey='artifactory.task.npm.header.publishingRepo' name='artifactory.task.npm.publishingRepo' list=dummyList
    listKey='repoKey' listValue='repoKey' toggle='true'/]

    [@ww.textfield labelKey='artifactory.task.npm.header.deployerUsername' name='artifactory.task.npm.deployerUsername'/]

    [@ww.password labelKey='artifactory.task.npm.header.deployerPassword' name='artifactory.task.npm.deployerPassword' showPassword='true'/]
    [#--The Dummy password is a workaround for the autofill (Chrome)--]
    [@ww.password name='artifactory.password.DUMMY' cssStyle='visibility:hidden; position: absolute'/]
    </div>
[/@ui.bambooSection]

[@ww.checkbox labelKey='artifactory.task.captureBuildInfo' name='captureBuildInfo' toggle='true'/]
[@ui.bambooSection dependsOn='captureBuildInfo' showOn=true]
    [#include 'editEnvVarsSnippet.ftl'/]
[/@ui.bambooSection]


<script type="text/javascript">

    function displayResolutionNpmArtifactoryConfigs(serverId) {
        var configDiv = document.getElementById('npmArtifactoryResolvingConfigDiv');
        var credentialsUserName = configDiv.getElementsByTagName('input')[1].value;
        var credentialsPassword = configDiv.getElementsByTagName('input')[2].value;

        if ((serverId == null) || (serverId.length == 0) || (-1 == serverId)) {
            configDiv.style.display = 'none';
        } else {
            configDiv.style.display = 'block';
            var urlSelect = document.getElementsByName('artifactory.task.npm.resolutionArtifactoryServerId')[0];
            var urlOptions = urlSelect.options;
            for (var i = 0; i < urlOptions.length; i++) {
                var option = urlOptions[i];
                if (option.value == '' + serverId) {
                    urlSelect.selectedIndex = i;
                    break;
                }
            }
            loadNpmResolvingRepoKeys(serverId, credentialsUserName, credentialsPassword)
        }
    }

    function loadNpmResolvingRepoKeys(serverId, credentialsUserName, credentialsPassword) {
        AJS.$.ajax({
            url: '${req.contextPath}/plugins/servlet/artifactoryConfigServlet?serverId=' + serverId +
                '&resolvingRepos=true&user=' + credentialsUserName + '&password=' + credentialsPassword,
            dataType: 'json',
            cache: false,
            success: function (json) {
                var repoSelect = document
                    .getElementsByName('artifactory.task.npm.resolutionRepo')[0];
                repoSelect.innerHTML = '';
                if (serverId >= 0) {

                    var selectedRepoKey = '${selectedResolutionRepoKey}';

                    for (var i = 0, l = json.length; i < l; i++) {
                        var deployableRepoKey = json[i];
                        var option = document.createElement('option');
                        option.innerHTML = deployableRepoKey;
                        option.value = deployableRepoKey;
                        repoSelect.appendChild(option);
                        if (selectedRepoKey && (deployableRepoKey == selectedRepoKey)) {
                            repoSelect.selectedIndex = i;
                        }
                    }
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                var errorMessage = 'An error has occurred while retrieving the resolving repository list.<br>' +
                    'Response: ' + XMLHttpRequest.status + ', ' + XMLHttpRequest.statusText + '.<br>';
                if (XMLHttpRequest.status == 404) {
                    errorMessage +=
                        'Please make sure that the Artifactory Server Configuration Management Servlet is accessible.'
                } else {
                    errorMessage +=
                        'Please check the server logs for error messages from the Artifactory Server Configuration Management Servlet.'
                }
                errorMessage += "<br>";
                errorDiv.innerHTML += errorMessage;
                errorDiv.style.display = '';
            }
        });
    }

    function displayPublishingNpmArtifactoryConfigs(serverId) {
        var configDiv = document.getElementById('npmArtifactoryPublishingConfigDiv');
        var credentialsUserName = configDiv.getElementsByTagName('input')[1].value;
        var credentialsPassword = configDiv.getElementsByTagName('input')[2].value;

        if ((serverId == null) || (serverId.length == 0) || (-1 == serverId)) {
            configDiv.style.display = 'none';
        } else {
            configDiv.style.display = 'block';
            var urlSelect = document.getElementsByName('artifactory.task.npm.artifactoryServerId')[0];
            var urlOptions = urlSelect.options;
            for (var i = 0; i < urlOptions.length; i++) {
                var option = urlOptions[i];
                if (option.value == '' + serverId) {
                    urlSelect.selectedIndex = i;
                    break;
                }
            }
            loadNpmPublishRepoKeys(serverId, credentialsUserName, credentialsPassword)
        }
    }

    function loadNpmPublishRepoKeys(serverId, credentialsUserName, credentialsPassword) {
        AJS.$.ajax({
            url: '${req.contextPath}/plugins/servlet/artifactoryConfigServlet?serverId=' + serverId +
                    '&deployableRepos=true&user=' + credentialsUserName + '&password=' + credentialsPassword,
            dataType: 'json',
            cache: false,
            success: function (json) {
                var repoSelect = document
                        .getElementsByName('artifactory.task.npm.publishingRepo')[0];
                repoSelect.innerHTML = '';
                if (serverId >= 0) {

                    var selectedRepoKey = '${selectedPublishingRepoKey}';

                    for (var i = 0, l = json.length; i < l; i++) {
                        var deployableRepoKey = json[i];
                        var option = document.createElement('option');
                        option.innerHTML = deployableRepoKey;
                        option.value = deployableRepoKey;
                        repoSelect.appendChild(option);
                        if (selectedRepoKey && (deployableRepoKey == selectedRepoKey)) {
                            repoSelect.selectedIndex = i;
                        }
                    }
                }
            },
            error: function (XMLHttpRequest, textStatus, errorThrown) {
                var errorMessage = 'An error has occurred while retrieving the publishing repository list.<br>' +
                        'Response: ' + XMLHttpRequest.status + ', ' + XMLHttpRequest.statusText + '.<br>';
                if (XMLHttpRequest.status == 404) {
                    errorMessage +=
                            'Please make sure that the Artifactory Server Configuration Management Servlet is accessible.'
                } else {
                    errorMessage +=
                            'Please check the server logs for error messages from the Artifactory Server Configuration Management Servlet.'
                }
                errorMessage += "<br>";
                errorDiv.innerHTML += errorMessage;
                errorDiv.style.display = '';
            }
        });
    }


    var errorDiv = document.getElementById('artifactory-error');
    errorDiv.innerHTML = '';

    displayPublishingNpmArtifactoryConfigs(${selectedPublishingServerId});
    displayResolutionNpmArtifactoryConfigs(${selectedResolutionServerId});
</script>