<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Quit">NOTE: Terminates the current connection.
    Short Term Implant:
         The implant will attempt to delete itself.
    Long Term Implant:
         The implant is not affected.
</xsl:template>

</xsl:transform>