<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="NetBios"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="NetBios">
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">verbose</xsl:attribute>
      <xsl:attribute name="value">true</xsl:attribute>
    </xsl:element>
   <xsl:apply-templates select="Adapter" />
  </xsl:template>

  <xsl:template match="Adapter">
    <xsl:apply-templates select="Names" />
   
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">adapter_addr</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@adapter_addr"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">adapter_type</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@adapter_type"/></xsl:attribute>
    </xsl:element>

    <!-- general information -->

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">release</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@release"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">duration</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@duration"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">name_count</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@name_count"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">frame_recv</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@frame_recv"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">frame_xmit</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@frame_xmit"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">iframe_recv_err</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@iframe_recv_err"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">xmit_aborts</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@xmit_aborts"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">xmit_success</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@xmit_success"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">recv_success</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@recv_success"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">iframe_xmit_err</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@iframe_xmit_err"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">recv_buff_unavail</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@recv_buff_unavail"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">t1_timeouts</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@t1_timeouts"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">ti_timeouts</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@ti_timeouts"/></xsl:attribute>
    </xsl:element>

    <!-- Packet Information -->

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">free_ncbs</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@free_ncbs"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">max_dgram_size</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@max_dgram_size"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">max_sess_pkt_size</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@max_sess_pkt_size"/></xsl:attribute>
    </xsl:element>

    <!-- Session Information -->

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">pending_sess</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@pending_sess"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">max_cfg_sess</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@max_cfg_sess"/></xsl:attribute>
    </xsl:element>

    <!-- Undefined properties -->

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">reserved0</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@reserved0"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">reserved1</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@reserved1"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">max_cfg_ncbs</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@max_cfg_ncbs"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">max_ncbs</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@max_ncbs"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">xmit_buf_unavail</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@xmit_buf_unavail"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">max_sess</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@max_sess"/></xsl:attribute>
    </xsl:element>




    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">size</xsl:attribute>
      <xsl:choose>
	<xsl:when test="number(@size) &gt;= 4294967296">
	  <!-- greater than 4 gigs -->
	  <xsl:attribute name="value">4294967296</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:attribute name="value"><xsl:value-of select="@size"/></xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">isdir</xsl:attribute>
      <xsl:choose>
	<xsl:when test="FileAttributeDirectory">
	    <xsl:attribute name="value">true</xsl:attribute>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:attribute name="value">false</xsl:attribute>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Names">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Name"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">netname</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="NetName"/></xsl:attribute>
    </xsl:element>
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">type</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="Type"/></xsl:attribute>
    </xsl:element>
  </xsl:template>

</xsl:transform>