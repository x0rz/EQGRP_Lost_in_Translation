<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Module">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">module_name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="ModuleName"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">checksum</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Checksum"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">entry_point</xsl:attribute>
      <xsl:attribute name="value"><xsl:text>0x</xsl:text><xsl:value-of select="@entry_point"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">image_size</xsl:attribute>
      <xsl:attribute name="value"><xsl:text>0x</xsl:text><xsl:value-of select="@image_size"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">base_address</xsl:attribute>
      <xsl:attribute name="value"><xsl:text>0x</xsl:text><xsl:value-of select="@base_address"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="BasicInfo">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">user_name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="User/."/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">user_type</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="User/@user_type"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">user_attr</xsl:attribute>
      <xsl:attribute name="value"><xsl:text>0x</xsl:text><xsl:value-of select="User/@user_attr"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">owner</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Owner/."/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">owner_type</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Owner/@owner_type"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">primary_group</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Group/."/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">prim_group_type</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Group/@primaryGroup_type"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

  <xsl:template match="GroupInfo">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">group_name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@name"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">group_type</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@type"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">group_attr</xsl:attribute>
      <xsl:attribute name="value"><xsl:text>0x</xsl:text><xsl:value-of select="@attr"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">group_enabled</xsl:attribute>
      <xsl:choose>
        <xsl:when test="SE_GROUP_ENABLED">
          <xsl:attribute name="value">true</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">group_enabled_by_default</xsl:attribute>
      <xsl:choose>
        <xsl:when test="SE_GROUP_ENABLED_BY_DEFAULT ">
          <xsl:attribute name="value">true</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">group_logon_id</xsl:attribute>
      <xsl:choose>
        <xsl:when test="SE_GROUP_LOGON_ID ">
          <xsl:attribute name="value">true</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">group_mandatory</xsl:attribute>
      <xsl:choose>
        <xsl:when test="SE_GROUP_MANDATORY ">
          <xsl:attribute name="value">true</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">group_owner</xsl:attribute>
      <xsl:choose>
        <xsl:when test="SE_GROUP_OWNER ">
          <xsl:attribute name="value">true</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">group_resource</xsl:attribute>
      <xsl:choose>
        <xsl:when test="SE_GROUP_RESOURCE ">
          <xsl:attribute name="value">true</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">group_use_deny</xsl:attribute>
      <xsl:choose>
        <xsl:when test="SE_GROUP_USE_FOR_DENY_ONLY ">
          <xsl:attribute name="value">true</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Privilege">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">privilege</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@name"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">priv_attr</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@attributes"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">priv_enabled</xsl:attribute>
      <xsl:choose>
        <xsl:when test="SE_PRIVILEGE_ENABLED">
          <xsl:attribute name="value">true</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">priv_enabled_by_default</xsl:attribute>
      <xsl:choose>
        <xsl:when test="SE_PRIVILEGE_ENABLED_BY_DEFAULT ">
          <xsl:attribute name="value">true</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">priv_used_access</xsl:attribute>
      <xsl:choose>
        <xsl:when test="SE_PRIVILEGE_USED_FOR_ACCESS">
          <xsl:attribute name="value">true</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="value">false</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

</xsl:transform>