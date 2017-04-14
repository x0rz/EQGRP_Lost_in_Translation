<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="UserModified">
		<xsl:text>User authentication modified</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Password is now: ZAQ!nji(</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>