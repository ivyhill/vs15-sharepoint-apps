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
    <script type="text/javascript" src="../Scripts/angular.min.js"></script>
    <script type="text/javascript">
        var urlParams;
        $(document).ready(function () {

            //alert(getUrlPath());
            //var foo = getParameterByName('lookupID');
            //alert(urlParams["lookupID"]);
            //var url = window.location.protocol + "//" + window.location.host + _spPageContextInfo.siteServerRelativeUrl;
            var testUrl = "_api/web/lists/getbytitle('AuditChecklist')/items?$filter=Title%20eq%20'123456789'";
            //execRESTListRequest(testUrl, createDivs)

            //angular js test
            var myAngApp = angular.module('SharePointAngApp', []);
            myAngApp.controller('spCustomerController', function ($scope, $http) {
                $http({
                    method: 'GET',
                    url: getUrlPath() + "/_api/web/lists/getbytitle('AuditChecklist')/items?$filter=Title%20eq%20'123456789'",
                    headers: { "Accept": "application/json;odata=verbose" }
                }).success(function (data, status, headers, config) {
                    $scope.questions = data.d.results;
                }).error(function (data, status, headers, config) {

                });
            });
        });

        function execRESTListRequest(url, resultFunction) {
            var url = getUrlPath() + url;
            $.ajax({
                url: url,
                method: "GET",
                headers: { "Accept": "application/json; odata=verbose" },
                success: resultFunction,
                error: function (error) {
                    alert(JSON.stringify(error));
                }
            });
        }

        function createDivs(data) {
            var lists = data.d.results;
            alert("works");
        }


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
    <form runat="server">
        <SharePoint:FormDigest ID="FormDigest1" runat="server"></SharePoint:FormDigest>
    </form>
    <div id="auditArea">hardcoded for now until getting query string to work might might be able to work around it</div>
    <br />
    <br />
    <div ng-app="SharePointAngApp" class="row">
        <div ng-controller="spCustomerController" class="span10">
            <div ng-repeat="x in questions" style="padding-bottom: 5px">
                <div style="display: inline-block">
                    Audit #:
                </div>
                <div style="display: inline-block">
                    {{customer.Title}}
                </div>
                <div>
                    <div style="display: inline-block">CL-ID:</div>
                    <div style="display: inline-block">{{customer.CL_x002d_ID}}</div>
                </div>
                <div>
                    <div style="display: inline-block">Question:</div>
                    <div style="display: inline-block">{{customer.Question}}</div>
                </div>
            </div>
        </div>
        <table class="table table-condensed table-hover">
            <tr>
                <th>Title</th>
            </tr>
            <tr ng-repeat="x in questions">
                <td></td>
            </tr>
        </table>
    </div>
    </div>
</body>
</html>
