<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="Group">
  <xsl:text>     Id : </xsl:text>
  <xsl:value-of select="@group_id" />
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>  Group : </xsl:text>
  <xsl:value-of select="@group" />
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>Comment : </xsl:text>
  <xsl:value-of select="@comment" />
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>Attributes (</xsl:text>
   <xsl:value-of select="Attributes/@mask" />
  <xsl:text>)&#x0D;&#x0A;</xsl:text>

  <xsl:if test="Attributes/SeGroupMandatory">
   <xsl:text>&#x09;SE_GROUP_MANDATORY</xsl:text>
   <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:if>

  <xsl:if test="Attributes/SeGroupEnabled">
   <xsl:text>&#x09;SE_GROUP_ENABLED</xsl:text>
   <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:if>

  <xsl:if test="Attributes/SeGroupEnabledByDefault">
   <xsl:text>&#x09;SE_GROUP_ENABLED_BY_DEFAULT</xsl:text>
   <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:if>

  <xsl:if test="Attributes/SeGroupLogonId">
   <xsl:text>&#x09;SE_GROUP_LOGON_ID</xsl:text>
   <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:if>

  <xsl:if test="Attributes/SeGroupOwner">
   <xsl:text>&#x09;SE_GROUP_OWNER</xsl:text>
   <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:if>

  <xsl:if test="Attributes/SeGroupResource">
   <xsl:text>&#x09;SE_GROUP_RESOURCE</xsl:text>
   <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:if>

  <xsl:if test="Attributes/SeGroupUseForDenyOnly">
   <xsl:text>&#x09;SE_GROUP_USE_FOR_DENY_ONLY</xsl:text>
   <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:if>

  <xsl:text>-------------------------------------------------</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>
</xsl:transform>