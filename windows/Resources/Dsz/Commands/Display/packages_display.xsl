<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="PackageList">
		<xsl:apply-templates select="Package"/>
	</xsl:template>
	
	<xsl:template match="Package">
		
		<xsl:text>        Name : </xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text> Description : </xsl:text>
		<xsl:value-of select="@desc"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>     Version : </xsl:text>
		<xsl:value-of select="@version"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>    Revision : </xsl:text>
		<xsl:value-of select="@revision"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>        Size : </xsl:text>
		<xsl:value-of select="@size"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:if test="InstallDate/@type != 'invalid'">
			<xsl:text>Install Date : </xsl:text>
			<xsl:value-of select="substring-before(InstallDate, 'T')"/>
       		<xsl:text> </xsl:text>
       		<xsl:value-of select="substring-before(substring-after(InstallDate, 'T'), '.')"/> 
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		
		<xsl:text>-------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>