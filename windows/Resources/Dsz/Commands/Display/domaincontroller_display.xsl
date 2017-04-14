<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:import href="include/StandardTransforms.xsl"/>
  
<xsl:template match="DomainController">	
	<xsl:call-template name="PrintReturn" />
	<xsl:text>DC Name         : </xsl:text>	
        <xsl:value-of select="DCName"/>
	<xsl:call-template name="PrintReturn" />

	<xsl:choose>
	<xsl:when test="ExtendedErrorInfo">
		<xsl:call-template name="PrintReturn" />
		<xsl:text>* Failed to get extended information:</xsl:text>
		<xsl:call-template name="PrintReturn"/>
		<xsl:text>    </xsl:text>
		<xsl:value-of select="ExtendedErrorInfo/QueryError"/>
		<xsl:call-template name="PrintReturn"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>DC Full Name    : </xsl:text>		
          <xsl:value-of select="DCFullName"/>
	  <xsl:call-template name="PrintReturn" />
	  <xsl:text>DC Address      : </xsl:text>		
          <xsl:value-of select="DCAddress"/>
	  <xsl:choose>
		  <xsl:when test="DCAddress/@addrType='IPAddress'">
			  <xsl:text> (IP Address)</xsl:text>
		  </xsl:when>
		  <xsl:when test="domainControllerAddress/@addrType='DS_NETBIOS_ADDRESS'">
			  <xsl:text> (NetBIOS Name)</xsl:text>
		  </xsl:when>
		  <xsl:otherwise>
			  <xsl:text> (Unknown) </xsl:text>
		  </xsl:otherwise>
	  </xsl:choose>
	  <xsl:call-template name="PrintReturn" />
	  <xsl:text>Domain GUID     : </xsl:text>	       	
          <xsl:value-of select="DomainGuid"/>
	  <xsl:call-template name="PrintReturn" />
	  <xsl:text>Domain Name     : </xsl:text>		
          <xsl:value-of select="DomainName"/>
	  <xsl:call-template name="PrintReturn" />
	  <xsl:text>DNS Forest Name : </xsl:text>		
          <xsl:value-of select="DnsForestName"/>
	  <xsl:call-template name="PrintReturn" />
	  <xsl:text>DC Site Name    : </xsl:text>		
          <xsl:value-of select="DCSiteName"/>
	  <xsl:call-template name="PrintReturn" />
	  <xsl:text>Client Site Name: </xsl:text>		
          <xsl:value-of select="ClientSiteName"/>
	  <xsl:call-template name="PrintReturn" /> 
	  <xsl:text>Properties      : </xsl:text>
	  <xsl:call-template name="PrintReturn" /> 	   	
	  <xsl:if test="Properties/Primary">
		  <xsl:text>                  Primary Domain Controller</xsl:text>
		  <xsl:call-template name="PrintReturn" />
	  </xsl:if>
	  <xsl:if test="Properties/Backup">
		  <xsl:text>                  Backup Domain Controller</xsl:text>
		  <xsl:call-template name="PrintReturn" />
	  </xsl:if>
	  <xsl:if test="Properties/KerberosKeyDistCenter">
		  <xsl:text>                  Kerberos Key Distribution Center</xsl:text>
		  <xsl:call-template name="PrintReturn" />
	  </xsl:if>	
	  <xsl:if test="Properties/GlobalCatalog">
		  <xsl:text>                  Global Catalog Server </xsl:text>
	        <xsl:call-template name="PrintReturn" />	
	  </xsl:if>	
	  <xsl:if test="Properties/DirectoryService">
		  <xsl:text>                  Directory Service Server</xsl:text>
		  <xsl:call-template name="PrintReturn" />
	  </xsl:if>	
	  <xsl:if test="Properties/TimeService">
		  <xsl:text>                  Windows Time Service Server</xsl:text>
		  <xsl:call-template name="PrintReturn" />
	  </xsl:if>
	  <xsl:if test="Properties/SAM">
		  <xsl:text>                  Writable Directory Service (SAM)</xsl:text>
		  <xsl:call-template name="PrintReturn" />		
	  </xsl:if>
	</xsl:otherwise>  
  </xsl:choose>
  <xsl:if test="AddlInformation">
	<xsl:call-template name="PrintReturn"/>
        <xsl:text>* Failed to get all domain controllers:</xsl:text>
	<xsl:call-template name="PrintReturn"/>
	<xsl:text>    </xsl:text>
	<xsl:value-of select="AddlInformation/EnumQueryError"/>
	<xsl:call-template name="PrintReturn"/>
  </xsl:if>
						
</xsl:template>

</xsl:transform>