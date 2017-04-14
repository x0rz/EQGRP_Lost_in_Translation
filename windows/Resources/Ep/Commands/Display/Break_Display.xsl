<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Break">NOTE: This command will terminate your connection.
           It does not otherwise affect the operation of the implant.
  </xsl:template>

</xsl:transform>