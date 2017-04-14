<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	
	<xsl:template match="FrzLinkActionCompleted">
		<xsl:text>Action completed</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
  
	<xsl:template match="FrzLinkState">
		<xsl:text> Link State : </xsl:text>
		<xsl:value-of select="@state"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="."/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="FrzLinks">
		<xsl:text> Found </xsl:text>
		<xsl:value-of select="@numLinks"/>
		<xsl:text> Links : </xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:apply-templates select="Link"/>
	</xsl:template>

	<xsl:template match="Link">
		<xsl:text>    </xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

	<xsl:template match="FrzLinkConfiguration">
		<xsl:text>              Link Provider : </xsl:text>
		<xsl:value-of select="@provider"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="@providerName"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>            Crypto Provider : </xsl:text>
		<xsl:value-of select="Crypto/@provider"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="Crypto/@providerName"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>                 Crypto Key : </xsl:text>
		<xsl:value-of select="Crypto/Key"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>Connection Manager Provider : </xsl:text>
		<xsl:value-of select="ConnectionMgr/@provider"/>
		<xsl:text> (</xsl:text>
		<xsl:value-of select="ConnectionMgr/@providerName"/>
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>                 Parameters : </xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:if test="string-length(Parameters) > 0">
			<xsl:call-template name="PrintBinary">
				<xsl:with-param name="data" select="Parameters"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
 
</xsl:transform>