<%@ Page Language="C#" Inherits="Microsoft.SharePoint.WebPartPages.WebPartPage, Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<WebPartPages:AllowFraming ID="AllowFraming" runat="server" />

<html>
<head>
    <title></title>

    <script type="text/javascript" src="../Scripts/jquery-1.9.1.min.js"></script>
    <script type="text/javascript" src="/_layouts/15/MicrosoftAjax.js"></script>
    <script type="text/javascript" src="/_layouts/15/sp.runtime.js"></script>
    <script type="text/javascript" src="/_layouts/15/sp.js"></script>
    <script type="text/javascript" src="/_layouts/15/SP.RequestExecutor.js"></script>

    <script type="text/javascript">
        var hostwebUrl
        var appwebUrl;
        var web;


        $(document).ready(function () {
            hostwebUrl = decodeURIComponent(getQueryStringParameter("SPHostUrl"));
            appwebUrl = decodeURIComponent(getQueryStringParameter("SPAppWebUrl"));
            var scriptbase = hostwebUrl + "/_layouts/15/";
            $.getScript(scriptbase + "SP.RequestExecutor.js");

            BindAuditDropdown();
            
            jQuery("#CreateQuestionsButton").click(function () {
                //alert("test");
                //getItems();
                //getListsXd();
                GetSelectedAudit();
            });

        });

        function getQueryStringParameter(paramToRetrieve) {
            var params =
                document.URL.split("?")[1].split("&");
            var strParams = "";
            for (var i = 0; i < params.length; i = i + 1) {
                var singleParam = params[i].split("=");
                if (singleParam[0] == paramToRetrieve)
                    return singleParam[1];
            }
        }


        /****************************************/
        function BindAuditDropdown() { execCrossDomainListRequest(); }
        //Cross Domain Call to obtain Host Web Lists
        function execCrossDomainListRequest() {
            var executor;
            executor = new SP.RequestExecutor(appwebUrl);
            var url = appwebUrl + "/_api/SP.AppContextSite(@target)/web/lists/getbytitle('Audit')/items?@target='" + hostwebUrl + "'";
            executor.executeAsync({
                url: url,
                method: "GET",
                headers: { "Accept": "application/json; odata=verbose" },
                success: AuditDropDownBind,
                error: errorListHandlerXD
            });
        }
        function AuditDropDownBind(data) {
            var jsonObject = JSON.parse(data.body);
            var lists = jsonObject.d.results;
            
            $.each(lists, function (index, list) {
                $('#AuditDropdownList').append($('<option/>', {
                    value: list.ID,
                    text: list.Title
                }));
            });
        }
        /**************************************/
        function GetSelectedAudit() { getAuditTypes();}
        function getAuditTypes() {
            
            var executor;
            executor = new SP.RequestExecutor(appwebUrl);
            var url = appwebUrl + "/_api/SP.AppContextSite(@target)/web/lists/getbytitle('Audit')/items?@target='" + hostwebUrl + "'";
            executor.executeAsync({
                url: url,
                method: "GET",
                headers: { "Accept": "application/json; odata=verbose" },
                success: GetSelectAudit,
                error: errorListHandlerXD
            });
        }
        function GetSelectAudit(data) {
            var jsonObject = JSON.parse(data.body);
            var lists = jsonObject.d.results;
            var auditTitle = $("#AuditDropdownList option:selected" ).text();
            var scheduleArray
            for (var item in lists)
            {
                if (lists[item].Title == auditTitle)
                {
                    var concatenatedScheduled = lists[item].Proposed_x0020_Schedule.results;
                    scheduleArray = concatenatedScheduled.toString().split(',');
                    alert(scheduleArray.length);
                }
            };

        }

        //Error Lists
        function errorListHandlerXD(data, errorCode, errorMessage) {
            $('#Label1').html("Could not complete cross-domain call: " + errorMessage);
        }



        /*Comes preloaded with this. mess with this later*/
        // Set the style of the client web part page to be consistent with the host web.
        (function () {
            'use strict';

            var hostUrl = '';
            if (document.URL.indexOf('?') != -1) {
                var params = document.URL.split('?')[1].split('&');
                for (var i = 0; i < params.length; i++) {
                    var p = decodeURIComponent(params[i]);
                    if (/^SPHostUrl=/i.test(p)) {
                        hostUrl = p.split('=')[1];
                        document.write('<link rel="stylesheet" href="' + hostUrl + '/_layouts/15/defaultcss.ashx" />');
                        break;
                    }
                }
            }
            if (hostUrl == '') {
                document.write('<link rel="stylesheet" href="/_layouts/15/1033/styles/themable/corev15.css" />');
            }
        })();
    </script>
</head>
<body>
    <div id="contentArea" style="width: 100%;">
        <div style="display: inline-block;">
            <select id="AuditDropdownList" style="width:150px;">
            </select>
            <input id="CreateQuestionsButton" type="button" value="Create Audit" />
        </div>
    </div>
</body>
</html>
