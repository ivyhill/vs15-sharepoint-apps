<%-- The following 4 lines are ASP.NET directives needed when using SharePoint components --%>

<%@ Page Inherits="Microsoft.SharePoint.WebPartPages.WebPartPage, Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" MasterPageFile="~masterurl/default.master" Language="C#" %>

<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<%-- The markup and script in the following Content element will be placed in the <head> of the page --%>
<asp:Content ContentPlaceHolderID="PlaceHolderAdditionalPageHead" runat="server">
    <script type="text/javascript" src="../Scripts/jquery-1.9.1.min.js"></script>
    <SharePoint:ScriptLink Name="sp.js" runat="server" OnDemand="true" LoadAfterUI="true" Localizable="false" />
    <meta name="WebPartPageExpansion" content="full" />

    <!-- Add your CSS styles to the following file -->
    <link rel="Stylesheet" type="text/css" href="../Content/App.css" />
    <link rel="Stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.12/css/jquery.dataTables.min.css" />

    <!-- Add your JavaScript to the following file -->
    <script type="text/javascript" src="../Scripts/App.js"></script>
    <script type="text/javascript" src="https://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.9.4/jquery.dataTables.min.js"></script>
    <script type="text/javascript">
        _spBodyOnLoadFunctionNames.push("runAfterEverythingElse");
        //global variables.
        var hostwebUrl
        var appwebUrl;
        var web;
        // This code runs when the DOM is ready and creates a context object which is needed to use the SharePoint object model
        /*Get the page ready*/
        $(document).ready(function () {
            hostwebUrl = decodeURIComponent(getQueryStringParameter("SPHostUrl"));
            appwebUrl = decodeURIComponent(getQueryStringParameter("SPAppWebUrl"));
            var scriptbase = hostwebUrl + "/_layouts/15/";
            $.getScript(scriptbase + "SP.RequestExecutor.js");

            jQuery("#Button1").click(function () {
                //alert("test");
                //getItems();
                getListsXd();
            });

            jQuery("#Button2").click(function () {
                //alert("test");
                //getItems();
                insertList();
            });

            getLists();

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

        /**************************/

        /*Button Click Get Lists Cross Domain*/
        function getListsXd() { execCrossDomainListRequest(); }
        //Cross Domain Call to obtain Host Web Lists
        function execCrossDomainListRequest() {
            var executor;
            executor = new SP.RequestExecutor(appwebUrl);
            var url = appwebUrl + "/_api/SP.AppContextSite(@target)/web/lists/getbytitle('Audit')/items?@target='" + hostwebUrl + "'";
            executor.executeAsync({
                url: url,
                method: "GET",
                headers: { "Accept": "application/json; odata=verbose" },
                success: successListHandlerXD,
                error: errorListHandlerXD
            });
        }
        //Success Lists
        function successListHandlerXD(data) {
            var jsonObject = JSON.parse(data.body);
            //Get LIsts
            var lists = jsonObject.d.results;
            $('#Label1').html("<b>Via Cross Domain the lists are:</b>");
            //Loop through each item adding to the label.
            var listsHtml = $.each(lists, function (index, list) {
                $('#Label1').append("Title: " + list.Title + " ");
            });

            for (var item in lists)
            { alert(lists[item].Title + " Schedule:" + lists[item].Proposed_x0020_Schedule.results); };
        }
        //Error Lists
        function errorListHandlerXD(data, errorCode, errorMessage) {
            $('#Label1').html("Could not complete cross-domain call: " + errorMessage);
        }


        /****************************************/
        //Obtains the path upto the actual application. E.g. http://app123.app.code/SubSite/CrossDomainApp
        //gets http://app123.app.com/SubSite
        function getUrlPath() {
            var webRel = _spPageContextInfo.webAbsoluteUrl;
            var lastIndex = webRel.lastIndexOf('/');
            var urlpath = webRel.substring(0, lastIndex);
            return urlpath;
        }

        //REST Call to obtain HostWeb Title
        function getLists() { execRESTListRequest(); }
        //REST Call to obtain HostWeb Lists
        function execRESTListRequest() {
            var url = getUrlPath() + "/_api/web/lists/getbytitle('Audit')/items";
            $.ajax({
                url: url,
                method: "GET",
                headers: { "Accept": "application/json; odata=verbose" },
                success: successListHandler,
                error: errorListHandler
            });
        }
        //Success List
        function successListHandler(data) {
            var lists = data.d.results;
            $('#Label2').html("<b>Via REST the lists are:</b><br/>");
            var listsHtml = $.each(lists, function (index, list) {
                $('#Label2').append("Title: " + list.Title + " ");
            });

            /*******/
            $('#testGridView').dataTable({
                "bDestroy": true,
                "bProcessing": true,
                "aaData": data.d.results,
                "aoColumns": [
                { "mData": "Title" }
                ]
            });
            /*******/


        }
        //Error Lists
        function errorListHandler(data, errorCode, errorMessage) {
            $('#Label2').html("Could not complete REST call: " + errorMessage);
        }



        /*****test insert area****/
        //REST Call to obtain HostWeb Title
        function insertList() {
            insertListRequest();
            //REST Call to obtain HostWeb Lists
            function insertListRequest() {
                var insertData = {
                    __metadata: { 'type': 'SP.Data.AuditListItem' },
                    Title: $("#insertText").val(),
                    Proposed_x0020_Schedule: { 'results': ['P - BD - 0001'] }
                };

                var url = getUrlPath() + "/_api/web/lists/getbytitle('Audit')/items";
                $.ajax({
                    url: url,
                    type: "POST",
                    headers: {
                        "accept": "application/json;odata=verbose",
                        "X-RequestDigest": $("#__REQUESTDIGEST").val(),
                        "content-Type": "application/json;odata=verbose"
                    },
                    data: JSON.stringify(insertData),
                    success: function (data) {
                        alert("inserted");
                    },
                    error: function (error) {
                        alert(JSON.stringify(error));
                    }
                });
            }
        }



    </script>
</asp:Content>

<%-- The markup in the following Content element will be placed in the TitleArea of the page --%>
<asp:Content ContentPlaceHolderID="PlaceHolderPageTitleInTitleArea" runat="server">
    Page Title
</asp:Content>

<%-- The markup and script in the following Content element will be placed in the <body> of the page --%>
<asp:Content ContentPlaceHolderID="PlaceHolderMain" runat="server">

    <div>
        <p id="message">
            <!-- The following content will be replaced with the user name when you run the app - see App.js -->
            initializing...
        </p>
    </div>
    <div style="margin: auto;">
        <br />
        <input id="Button1" type="button" value="test read" />
        <asp:Label ID="Label1" ClientIDMode="Static" runat="server" Text="Label"></asp:Label>
        <br />
        <br />
        <input id="Button2" type="button" value="test insert" />
        <input id="insertText" type="text" />
        <br />
    </div>
    <div style="width: 100%; margin: auto;">
        <span style="font-weight: bold;">Testing Gridview datatable.net </span>
        <br />
        <br />
        <asp:Label ID="Label2" ClientIDMode="Static" runat="server" Text="Label"></asp:Label>
        <br />
        <br />
        <br />
        <table width="100%" cellpadding="0" cellspacing="0" border="0" class="display" id="testGridView">
            <thead>
                <th>Title</th>
            </thead>
        </table>
        <br />
        <br />
    </div>

</asp:Content>
