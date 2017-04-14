<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="Services"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="Services">
	<xsl:apply-templates select="Service"/>
  </xsl:template>

  <xsl:template match="Service">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">service</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@name"/></xsl:attribute>
    </xsl:element>
    
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">display_name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@displayName"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">service_type</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="ServiceType/@value"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">service_owns_process</xsl:attribute>
      <xsl:choose>
       <xsl:when test="ServiceType/SERVICE_WIN32_OWN_PROCESS"><xsl:attribute name="value">true</xsl:attribute></xsl:when>
       <xsl:otherwise><xsl:attribute name="value">false</xsl:attribute></xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">service_shares_process</xsl:attribute>
      <xsl:choose>
       <xsl:when test="ServiceType/SERVICE_WIN32_SHARE_PROCESS"><xsl:attribute name="value">true</xsl:attribute></xsl:when>
       <xsl:otherwise><xsl:attribute name="value">false</xsl:attribute></xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">service_device_driver</xsl:attribute>
      <xsl:choose>
       <xsl:when test="ServiceType/SERVICE_KERNEL_DRIVER"><xsl:attribute name="value">true</xsl:attribute></xsl:when>
       <xsl:otherwise><xsl:attribute name="value">false</xsl:attribute></xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">service_file_system_driver</xsl:attribute>
      <xsl:choose>
       <xsl:when test="ServiceType/SERVICE_FILE_SYSTEM_DRIVER"><xsl:attribute name="value">true</xsl:attribute></xsl:when>
       <xsl:otherwise><xsl:attribute name="value">false</xsl:attribute></xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">service_interactive</xsl:attribute>
      <xsl:choose>
       <xsl:when test="ServiceType/SERVICE_INTERACTIVE_PROCESS"><xsl:attribute name="value">true</xsl:attribute></xsl:when>
       <xsl:otherwise><xsl:attribute name="value">false</xsl:attribute></xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">current_state</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@state"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">accepted_codes</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="AcceptedCodes/@value"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">accepts_stop</xsl:attribute>
      <xsl:choose>
       <xsl:when test="AcceptedCodes/SERVICE_ACCEPT_STOP"><xsl:attribute name="value">true</xsl:attribute></xsl:when>
       <xsl:otherwise><xsl:attribute name="value">false</xsl:attribute></xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">accepts_pause_continue</xsl:attribute>
      <xsl:choose>
       <xsl:when test="AcceptedCodes/SERVICE_ACCEPT_PAUSE_CONTINUE"><xsl:attribute name="value">true</xsl:attribute></xsl:when>
       <xsl:otherwise><xsl:attribute name="value">false</xsl:attribute></xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">accepts_shutdown</xsl:attribute>
      <xsl:choose>
       <xsl:when test="AcceptedCodes/SERVICE_ACCEPT_SHUTDOWN"><xsl:attribute name="value">true</xsl:attribute></xsl:when>
       <xsl:otherwise><xsl:attribute name="value">false</xsl:attribute></xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">accepts_param_change</xsl:attribute>
      <xsl:choose>
       <xsl:when test="AcceptedCodes/SERVICE_ACCEPT_PARAMCHANGE"><xsl:attribute name="value">true</xsl:attribute></xsl:when>
       <xsl:otherwise><xsl:attribute name="value">false</xsl:attribute></xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">accepts_net_bind_change</xsl:attribute>
      <xsl:choose>
       <xsl:when test="AcceptedCodes/SERVICE_ACCEPT_NETBINDCHANGE"><xsl:attribute name="value">true</xsl:attribute></xsl:when>
       <xsl:otherwise><xsl:attribute name="value">false</xsl:attribute></xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">accepts_hardware_prof_change</xsl:attribute>
      <xsl:choose>
       <xsl:when test="AcceptedCodes/SERVICE_ACCEPT_HARDWAREPROFILECHANGE"><xsl:attribute name="value">true</xsl:attribute></xsl:when>
       <xsl:otherwise><xsl:attribute name="value">false</xsl:attribute></xsl:otherwise>
      </xsl:choose>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">bool</xsl:attribute>
      <xsl:attribute name="name">accepts_power_event</xsl:attribute>
      <xsl:choose>
       <xsl:when test="AcceptedCodes/SERVICE_ACCEPT_POWEREVENT"><xsl:attribute name="value">true</xsl:attribute></xsl:when>
       <xsl:otherwise><xsl:attribute name="value">false</xsl:attribute></xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

</xsl:transform>