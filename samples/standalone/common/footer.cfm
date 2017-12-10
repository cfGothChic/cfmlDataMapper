<cfparam name="request.jsScripts" default="#[]#">

  </div>

  <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
  <script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>
  <cfoutput>
    <cfif arrayLen(request.jsScripts)>
      <cfloop array="#request.jsScripts#" index="local.script">
        <script src="../fw1/assets/js/#local.script#"></script>
      </cfloop>
    </cfif>
  </cfoutput>

</body>
</html>
