<!DOCTYPE html>

<cfset publicId = "TESTAPIKEY"/>
<cfset magic = "XSDE422RSDJQDJW8QADM31SMA"/>

<cfif isDefined('form.userId')>
	<cfset epochSeconds=DateDiff("s", "January 1 1970 00:00:00", now())/>

	<cfset h=lcase(hash( publicId&CGI.REMOTE_ADDR&epochSeconds&magic ))/>

	<cfset t="id=#publicId#&uid=#form.userId#&ip=#cgi.remote_addr#&ts=#epochSeconds#&hash=#h#"/>

	<cfhttp url="http://api.edmdesigner.com/api/token"
		method="post"
		result="tok"
		>
		<cfhttpparam type="header" name="Content-Type" value="application/x-www-form-urlencoded"/>
		<cfhttpparam type="body" value="#t#"/>
	</cfhttp>

	<cfcontent reset="true"><cfoutput>#tok.Filecontent#</cfoutput><cfabort/>
</cfif>
<html>
<head>
  <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
  <script src="http://api.edmdesigner.com/EDMdesignerAPI.js?route=testEdmDesigner.cfml"></script>
</head>
<body>
<script>
initEDMdesignerPlugin("pluginTest", function(edmPlugin) {
        function updateProjectList() {
			$("#NewProject").hide();
			$("#OpenedProject").hide();
			$("#Preview").hide();
			$("#EditProjectInfo").hide();
			$("#ProjectList").show();

			var projectListContainer = $("#ProjectListContent")
				.empty();

			edmPlugin.listProjects(function(result) {
				for(var idx = 0; idx < result.length; idx += 1) {
					projectListContainer.append(createProjectListElem(result[idx]));
				}
			});
		}

		function createProjectListElem(data) {
			var elem = $("<div class='project-list-elem'/>");
			var titleAndDescription = $("<div class='info'/>").appendTo(elem);
			var buttons = $("<div class='buttons'/>").appendTo(elem);

			titleAndDescription
				.append($("<h3/>").text(data.title))
				.append($("<p/>").text(data.description));

			var openButton = $("<button/>")
				.text("Open")
				.click(function() {
					edmPlugin.openProject(data._id, function (result) {
						openEditor(result.iframe);
					});
				})
				.appendTo(elem);

			var deleteButton = $("<button/>")
				.text("Delete")
				.click(function() {
					edmPlugin.removeProject(data._id, updateProjectList);
				})
				.appendTo(elem);

			var duplicateButton = $("<button/>")
				.text("Duplicate")
				.click(function() {
					edmPlugin.duplicateProject(data._id, updateProjectList);
				})
				.appendTo(elem);

			var previewButton = $("<button/>")
				.text("Preview")
				.click(function() {
					openPreview(data._id);
					edmPlugin.previewProject(data._id, openPreview);
				})
				.appendTo(elem);

			var EditProjectInfoButton = $("<button>")
				.text("Edit Project Info")
				.click(function() {
					$("#ProjectList").hide();
					var projInfo = $("#EditProjectInfo");
					projInfo.show();

					var titleInput = $("#ProjectTitleInput");
					var descrInput = $("#ProjectDescriptionTextarea");
					titleInput.val(data.title);
					descrInput.val(data.description);

					$("#ProjectInfoOk").click(function() {
						var title = titleInput.val();
						var descr = descrInput.val();

						titleInput.val("");
						descrInput.val("");

						projInfo.hide();
						edmPlugin.updateProjectInfo(data._id, {title: title, description: descr}, function(result) {
							updateProjectList();
						});
					});

					$("#ProjectInfoCancel").click(function() {
						updateProjectList();
					});
				})
				.appendTo(elem);

			return elem;
		}

		function openEditor(iframe) {
			var projectListContainer = $("#ProjectList")
				.hide();

			var closeDiv = $("<div/>");
			var closeButton = $("<button/>")
				.text("Close")
				.click(updateProjectList)
				.appendTo(closeDiv);

			var openedProjectContainer = $("#OpenedProject")
				.empty()
				.append(closeDiv)
				.append(iframe)
				.show();
		}

		function openPreview(result) {
			var projectListContainer = $("#ProjectList")
				.hide();

			$("#Preview").show();

			$("#PreviewCloseButton").click(updateProjectList);

			var previewIframe = $("#PreviewIframe");
			previewIframe.attr("src", result.src);
			//var previewIframeContents = previewIframe.contents().find("html");
			//previewIframeContents.html(htmlResult);

			previewIframe.width(240);
			previewIframe.height(500);

			$("#W240").click(function() {
				//previewIframe.width(240);
				previewIframe.width(240);
			});

			$("#W320").click(function() {
				previewIframe.width(320);
			});

			$("#W480").click(function() {
				previewIframe.width(480);
			});

			$("#W800").click(function() {
				previewIframe.width(800);
			});

			$("#W1024").click(function() {
				previewIframe.width(1024);
			});
		}

		$("#NewProjectButton").click(function() {
			$("#ProjectList").hide();
			$("#NewProject").show();
		});

		$("#NewProjectAddButton").click(function() {
			var titleInput = $("#NewProjectTitle"),
				descrInput = $("#NewProjectDescription");

			var data = {
				title: titleInput.val(),
				description: descrInput.val()
			};

			titleInput.val("");
			descrInput.val("");

			edmPlugin.createProject(data, updateProjectList);
		});


		$(document).ready(updateProjectList);
	}, function(error) {
		alert(error);
	});
</script>


<div>
	<h1>EDMdesigner-API-Example-ColdFusion</h1>
</div>

<div id="ProjectList">
	<button id="NewProjectButton">New project</button>
	<h2>Projects</h2>

	<div id="ProjectListContent">
	</div>
</div>

<div id="OpenedProject">
	<!-- An iframe will be inserted here -->
</div>

<div id="NewProject">
	<h2>New project</h2>
	<h3>Title</h3>
	<input id="NewProjectTitle"/>
	<h3>Description</h3>
	<textarea id="NewProjectDescription"></textarea>
	<div>
		<button id="NewProjectAddButton">Add</button>
	</div>
</div>

<div id="Preview">
	<h2>Preview</h2>
	<div>
		<button id="PreviewCloseButton">Close</button>
	</div>
	<div>
		<button id="W240">w: 240px</button>
		<button id="W320">w: 320px</button>
		<button id="W480">w: 480px</button>
		<button id="W800">w: 800px</button>
		<button id="W1024">w: 1024px</button>
	</div>

	<iframe id="PreviewIframe"></iframe>
</div>

<div id="EditProjectInfo">
	<h2>Edit project info</h2>
	<div>
		<input id="ProjectTitleInput" />
	</div>
	<textarea id="ProjectDescriptionTextarea"></textarea>
	<div>
		<button id="ProjectInfoOk">Ok</button>
		<button id="ProjectInfoCancel">Cancel</button>
	</div>
</div>

</body>
</html>
