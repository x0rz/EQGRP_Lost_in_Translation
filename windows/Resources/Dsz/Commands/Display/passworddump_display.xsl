<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="Passwords">
		<xsl:apply-templates select="WindowsPassword"/>
		<xsl:apply-templates select="WindowsSecret"/>
		<xsl:apply-templates select="UnixPassword"/>
		<xsl:apply-templates select="DigestPassword"/>
	</xsl:template>
	
	<xsl:template match="WindowsPassword">
		<xsl:text>       User : </xsl:text>
		<xsl:value-of select="@user"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>        Rid : </xsl:text>
		<xsl:value-of select="@rid"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>    Expired : </xsl:text>
		<xsl:value-of select="@expired"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>  Exception : </xsl:text>
		<xsl:value-of select="@exception"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>Lanman Hash : </xsl:text>
		<xsl:value-of select="LanmanHash"/>
		<xsl:if test="LanmanHash/@isEmptyString = 'true'">
			<xsl:text> (Empty string)</xsl:text>
		</xsl:if>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>    Nt Hash : </xsl:text>
		<xsl:value-of select="NtHash"/>
		<xsl:if test="NtHash/@isEmptyString = 'true'">
			<xsl:text> (Empty string)</xsl:text>
		</xsl:if>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="WindowsSecret">
		<xsl:text>Secret : </xsl:text>
		<xsl:value-of select="Name"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text> Value :</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:if test="string-length(Value) &gt; 0">
			<xsl:call-template name="PrintBinary">
				<xsl:with-param name="data" select="Value"/>
			</xsl:call-template>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
		
		<xsl:text>------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
  	<xsl:template match="UnixPassword">
		<xsl:text>       User : </xsl:text>
		<xsl:value-of select="@user"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>       Hash : </xsl:text>
		<xsl:value-of select="@hash"/>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>    Expired : </xsl:text>
		<xsl:value-of select="@expired"/>
		<xsl:call-template name="PrintReturn"/>
				
		<xsl:text>------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	<xsl:template match="DigestPassword">
		<xsl:text>       User : </xsl:text>
		<xsl:value-of select="Name"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>     Domain : </xsl:text>
		<xsl:value-of select="Domain"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>   Password : </xsl:text>
		<xsl:value-of select="Password"/>
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
</xsl:transform>