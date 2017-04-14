<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  
	<xsl:template match="Groups">
		<xsl:apply-templates select="Group"/>
	</xsl:template>
	
	<xsl:template match="Group">
	
		<xsl:text>-------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>     Group : </xsl:text>
		<xsl:value-of select="@group" />
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>   Comment : </xsl:text>
		<xsl:value-of select="@comment" />
		<xsl:call-template name="PrintReturn"/>

		<xsl:text>        Id : </xsl:text>
		<xsl:value-of select="@groupId" />
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>Attributes : </xsl:text>
		<xsl:call-template name="PrintReturn"/>

		<xsl:if test="Attributes/SeGroupMandatory">
			<xsl:text>    SE_GROUP_MANDATORY</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>

		<xsl:if test="Attributes/SeGroupEnabled">
			<xsl:text>    SE_GROUP_ENABLED</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>

		<xsl:if test="Attributes/SeGroupEnabledByDefault">
			<xsl:text>    SE_GROUP_ENABLED_BY_DEFAULT</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>

		<xsl:if test="Attributes/SeGroupLogonId">
			<xsl:text>    SE_GROUP_LOGON_ID</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>

		<xsl:if test="Attributes/SeGroupOwner">
			<xsl:text>    SE_GROUP_OWNER</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>

		<xsl:if test="Attributes/SeGroupResource">
			<xsl:text>    SE_GROUP_RESOURCE</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>

		<xsl:if test="Attributes/SeGroupUseForDenyOnly">
			<xsl:text>    SE_GROUP_USE_FOR_DENY_ONLY</xsl:text>
			<xsl:call-template name="PrintReturn"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="Success">
		<xsl:text>-------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>Group listing complete</xsl:text>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>

</xsl:transform>