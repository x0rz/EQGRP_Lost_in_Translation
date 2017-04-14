<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:import href="StandardTransforms.xsl"/>
 <xsl:output method="text"/>

 <xsl:template match="BasicInfo">
  <xsl:text>         User : </xsl:text>
  <xsl:value-of select="User" />
  <xsl:text> (Type=</xsl:text>
  <xsl:value-of select="User/@user_type" />
  <xsl:text> | Attributes=</xsl:text>
  <xsl:value-of select="User/@user_attr" />
  <xsl:text>)</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>        Owner : </xsl:text>
  <xsl:value-of select="Owner"/>
  <xsl:text> (Type=</xsl:text>
  <xsl:value-of select="Owner/@owner_type" />
  <xsl:text> | Attributes=</xsl:text>
  <xsl:value-of select="Owner/@owner_attr" />
  <xsl:text>)</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>Primary Group : </xsl:text>
  <xsl:value-of select="Group"/>
  <xsl:text> (Type=</xsl:text>
  <xsl:value-of select="Group/@primaryGroup_type" />
  <xsl:text> | Attributes=</xsl:text>
  <xsl:value-of select="Group/@primaryGroup_attr" />
  <xsl:text>)</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="StartGroups">
  <xsl:text>Groups:</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="GroupInfo">
  <xsl:text>     </xsl:text>
  <xsl:value-of select="@name" />
  <xsl:text> (Type=</xsl:text>
  <xsl:value-of select="@type" />
  <xsl:text> |  Attributes=</xsl:text>
  <xsl:value-of select="@attr" />
  <xsl:text>)</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:for-each select="descendant::*">
    <xsl:text>&#x09;</xsl:text>
    <xsl:value-of select="name(.)"/>
    <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:for-each>
 </xsl:template>

 <xsl:template match="StartPrivs">
	<xsl:text>Privileges:</xsl:text>
	<xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>
 
 <xsl:template match="StartBasic" />

 <xsl:template match="Privilege">
  <xsl:text>     </xsl:text>
  <xsl:value-of select="@name" />
  <xsl:text> (Attributes=</xsl:text>
  <xsl:value-of select="@attributes" />
  <xsl:text>)</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:choose>
    <xsl:when test="count(descendant::*) > 0">
	<xsl:for-each select="descendant::*">
	    <xsl:text>&#x09;</xsl:text>
	    <xsl:value-of select="name(.)"/>
	    <xsl:text>&#x0D;&#x0A;</xsl:text>
	</xsl:for-each>
    </xsl:when>
    <xsl:otherwise>
	<xsl:text>&#x09;SE_PRIVILEGE_DISABLED&#x0D;&#x0A;</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template match="Attr">
  <xsl:text>        </xsl:text>
  <xsl:value-of select="." />
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="StartMods">
  <xsl:text>--Loaded Modules--</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>Entry Point  Image Size  Base Address  Checksum</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <xsl:text>--------------------------------------------------</xsl:text>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>

 <xsl:template match="Module">
  <xsl:value-of select="ModuleName" />
  <xsl:text>&#x0D;&#x0A;</xsl:text>

  <xsl:text>  </xsl:text>  
  <xsl:value-of select="@entry_point" />
  <xsl:call-template name="Whitespace">
   <xsl:with-param name="i" select="12 - string-length(@entry_point)" /> 
  </xsl:call-template>
  <xsl:value-of select="@image_size" />
  <xsl:call-template name="Whitespace">
   <xsl:with-param name="i" select="14 - string-length(@image_size)" /> 
  </xsl:call-template>
  <xsl:value-of select="@base_address" />
  <xsl:call-template name="Whitespace">
   <xsl:with-param name="i" select="11 - string-length(@base_address)" /> 
  </xsl:call-template>
  <xsl:value-of select="Checksum" />
  <xsl:text>&#x0D;&#x0A;</xsl:text>
 </xsl:template>

</xsl:transform>