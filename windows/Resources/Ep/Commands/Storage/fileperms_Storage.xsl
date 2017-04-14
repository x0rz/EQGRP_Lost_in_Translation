<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="StandardTransforms.xsl"/>

  <xsl:output method="xml" omit-xml-declaration="no"/>

  <xsl:template match="/"> 
	<xsl:element name="StorageNodes">
	    <xsl:apply-templates select="FilePerms"/>
	</xsl:element>
  </xsl:template>

  <xsl:template match="FilePerms">
    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">account_name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@accountName"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">domain_name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@domainName"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">group_domain_name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@groupDomainName"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">group_name</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@groupName"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">num_security_aces</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="count(Acl[@type = '0']/Ace)"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">num_object_aces</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="count(Acl[@type = '1']/Ace)"/></xsl:attribute>
    </xsl:element>

    <xsl:apply-templates select="Acl"/>

  </xsl:template>

  <xsl:template match="Acl">
    <xsl:apply-templates select="Ace"/>
  </xsl:template>

  <xsl:template match="Ace">
    <xsl:element name="Storage">
      <xsl:attribute name="type">int</xsl:attribute>
      <xsl:attribute name="name">ace_type</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@type"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">domain</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@domain"/></xsl:attribute>
    </xsl:element>

    <xsl:element name="Storage">
      <xsl:attribute name="type">string</xsl:attribute>
      <xsl:attribute name="name">user</xsl:attribute>
      <xsl:attribute name="value"><xsl:value-of select="@user"/></xsl:attribute>
    </xsl:element>

    <!-- NOTE:	The code below does not apply these correctly.  In order to save these
		correctly, the name of the storage values (ie, "container_inherit_ace") needs
	  	to change for each ACE.  Otherwise, there is no way to line up the values to
		the ACEs.

    <xsl:apply-templates select="Flags"/>
    <xsl:apply-templates select="Mask"/>
	-->

  </xsl:template>

<!--
  <xsl:template match="Flags">
    <xsl:choose>
	<xsl:when test="ContainerInheritAce">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">container_inherit_ace</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">container_inherit_ace</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="InheritOnlyAce">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">inherit_only_ace</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">inherit_only_ace</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="InheritedAce">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">inherited_ace</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">inherited_ace</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="NoPropogateInheritAce">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">no_propagate_inherit_ace</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">no_propagate_inherit_ace</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="ObjectInheritAce">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">object_inherit</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">object_inherit</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="FailedAccessAce">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">failed_access_ace</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">failed_access_ace</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="SuccessfulAccessAce">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">successful_access_ace</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">successful_access_ace</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Mask">
    <xsl:choose>
	<xsl:when test="Delete">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">delete_mask</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">delete_mask</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="ExecuteMask">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">execute_file_mask</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">execute_file_mask</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="FileAppendData">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">file_append_data</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">file_append_data</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="FileDeleteChild">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">file_delete_child</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">file_delete_child</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="FileExecute">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">file_execute</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">file_execute</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="FileReadAttributes">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">file_read_attr</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">file_read_attr</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="FileReadData">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">file_read_data</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">file_read_data</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="FileReadEA">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">file_read_ea</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">file_read_ea</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="FileWriteAttributes">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">file_write_attr</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">file_write_attr</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="FileWriteData">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">file_write_data</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">file_write_data</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="FileWriteEA">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">file_write_ea</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">file_write_ea</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="FullControlMask">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">full_control_mask</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">full_control_mask</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="GenericReadMask">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">generic_read_mask</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">generic_read_mask</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="GenericWriteMask">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">generic_write_mask</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">generic_write_mask</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="ReadControl">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">read_control</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">read_control</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="ReadWriteMask">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">read_write_mask</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">read_write_mask</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="Synchronize">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">synchronize</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">synchronize</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="WriteDac">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">write_dac</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">write_dac</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
	<xsl:when test="WriteOwner">
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">write_owner</xsl:attribute>
	      <xsl:attribute name="value">true</xsl:attribute>
	    </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	    <xsl:element name="Storage">
	      <xsl:attribute name="type">bool</xsl:attribute>
	      <xsl:attribute name="name">write_owner</xsl:attribute>
	      <xsl:attribute name="value">false</xsl:attribute>
	    </xsl:element>
	</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
-->

</xsl:transform>