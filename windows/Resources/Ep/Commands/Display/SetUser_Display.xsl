<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="text"/>

  <xsl:template match="Revert">Reverted to original user
</xsl:template>

  <xsl:template match="Impersonate">Impersonating specified user for all new commands
</xsl:template>

</xsl:transform>