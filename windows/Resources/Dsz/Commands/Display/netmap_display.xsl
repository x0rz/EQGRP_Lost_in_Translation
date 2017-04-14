<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
	
	<xsl:template match="Entries">
		<xsl:apply-templates select="ExtendedError"/>
		<xsl:apply-templates select="Entry"/>
	</xsl:template>
	
	<xsl:template match="ExtendedError">
		<xsl:text>Extended Error Code                : (</xsl:text>
		<xsl:value-of select="@errorCode" />
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Extended Error Message             : (</xsl:text>
		<xsl:value-of select="Error" />
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Network Provider Raising the Error : (</xsl:text>
		<xsl:value-of select="Name" />
		<xsl:text>)</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="Entry">
		<xsl:text>----------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
		
		<xsl:value-of select="RemoteName" />
		<xsl:text> (Parent '</xsl:text>
		<xsl:value-of select="ParentName" />
		<xsl:text>')</xsl:text>
		<xsl:call-template name="PrintReturn" />

		<xsl:text>          Type : </xsl:text>
		<xsl:value-of select="Type" />
		<xsl:call-template name="PrintReturn" />

		<xsl:text>         Depth : </xsl:text>
		<xsl:value-of select="@level" />
		<xsl:call-template name="PrintReturn" />

		<xsl:text>    Local Name : </xsl:text>
		<xsl:value-of select="LocalName" />
		<xsl:call-template name="PrintReturn" />

		<xsl:text>       Comment : </xsl:text>
		<xsl:value-of select="Comment" />
		<xsl:call-template name="PrintReturn" />

		<xsl:text>      Provider : </xsl:text>
		<xsl:value-of select="Provider" />
		<xsl:call-template name="PrintReturn" />
		
		<xsl:for-each select="Addr">
			<xsl:text>       Address : </xsl:text>
			<xsl:value-of select="."/>
			<xsl:call-template name="PrintReturn" />
		</xsl:for-each>

		<xsl:if test="TimeOfDay">
			<xsl:text>          Time : </xsl:text>
			<xsl:call-template name="printTime">
				<xsl:with-param name="time" select="TimeOfDay"/>
			</xsl:call-template>
			<xsl:call-template name="PrintReturn" />
			<xsl:text>     TZ Offset : </xsl:text>
			<xsl:call-template name="PrintBias">
				<xsl:with-param name="bias" select="TimeZoneOffset"/>
			</xsl:call-template>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
		
		<xsl:if test="OsInfo">
			<xsl:text>   OS Platform : </xsl:text>
			<xsl:value-of select="OsInfo/@platformType"/>
			<xsl:call-template name="PrintReturn" />
			<xsl:text>    OS Version : </xsl:text>
			<xsl:value-of select="OsInfo/@osVersionMajor"/>
			<xsl:text>.</xsl:text>
			<xsl:value-of select="OsInfo/@osVersionMinor"/>
			<xsl:call-template name="PrintReturn" />
			<xsl:text>      Software : </xsl:text>
			<xsl:call-template name="PrintReturn" />
			<xsl:for-each select="OsInfo/Software">
				<xsl:text>          - </xsl:text>
				<xsl:value-of select="."/>
				<xsl:call-template name="PrintReturn" />
			</xsl:for-each>
		</xsl:if>

		<xsl:call-template name="PrintReturn" />
	</xsl:template>
  
	<xsl:template match="Success">
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Netmap Listing Complete</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>

	<xsl:template name="PrintBias">
		<xsl:param name="bias"/>

		<xsl:if test="$bias/@negative = 'true'">
			<xsl:text>-</xsl:text>
		</xsl:if>

		<xsl:value-of select="substring-before(substring-after($bias, 'T'), 'H')"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="substring-before(substring-after($bias, 'H'), 'M')"/>
		<xsl:text> (hours:minutes)</xsl:text>
	</xsl:template>
	
</xsl:transform>