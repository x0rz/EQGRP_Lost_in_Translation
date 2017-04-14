<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:import href="include/StandardTransforms.xsl"/>

 <xsl:template match="Services">
	<xsl:apply-templates select="Service" />
 </xsl:template>

  <xsl:template match="Service">
   <xsl:text>       Service : </xsl:text>
   <xsl:value-of select="@serviceName" />
   <xsl:call-template name="PrintReturn" />

   <xsl:text>  Display Name : </xsl:text>
   <xsl:value-of select="@displayName" />
   <xsl:call-template name="PrintReturn" />

	<xsl:text>         State : </xsl:text>
	<xsl:value-of select="State" />
	<xsl:call-template name="PrintReturn" />

	<xsl:apply-templates select="ServiceType" />
	
   <xsl:apply-templates select="AcceptedCodes" />
   <xsl:text>-----------------------------------------------------------------</xsl:text>
   <xsl:call-template name="PrintReturn" />

  </xsl:template>

  <xsl:template match="ServiceType">
   <xsl:text>          Type : </xsl:text>
   <xsl:call-template name="PrintReturn" />
   <xsl:if test="SERVICE_WIN32_OWN_PROCESS">
    <xsl:text>                 The service runs in its own process.</xsl:text>
    <xsl:call-template name="PrintReturn" />
   </xsl:if>
   <xsl:if test="SERVICE_WIN32_SHARE_PROCESS">
    <xsl:text>                 The service shares a process with other services.</xsl:text>
    <xsl:call-template name="PrintReturn" />
   </xsl:if>
   <xsl:if test="SERVICE_KERNEL_DRIVER">
    <xsl:text>                 The service is a device driver.</xsl:text>
    <xsl:call-template name="PrintReturn" />
   </xsl:if>
   <xsl:if test="SERVICE_FILE_SYSTEM_DRIVER">
    <xsl:text>                 The service is a file system driver.</xsl:text>
    <xsl:call-template name="PrintReturn" />
   </xsl:if>
   <xsl:if test="SERVICE_INTERACTIVE_PROCESS">
    <xsl:text>                 The service can interact with the desktop.</xsl:text>
    <xsl:call-template name="PrintReturn" />
   </xsl:if>
  </xsl:template>

  <xsl:template match="AcceptedCodes">
   <xsl:text>Accepted Codes : </xsl:text>
   <xsl:call-template name="PrintReturn" />
   
   <xsl:if test="SERVICE_ACCEPT_STOP">
    <xsl:text>                 The service can be stopped.</xsl:text>
    <xsl:call-template name="PrintReturn" />
   </xsl:if>
   <xsl:if test="SERVICE_ACCEPT_PAUSE_CONTINUE">
    <xsl:text>                 The service can be paused and continued.</xsl:text>
    <xsl:call-template name="PrintReturn" />
   </xsl:if>
   <xsl:if test="SERVICE_ACCEPT_SHUTDOWN">
    <xsl:text>                 The service is notified when system shutdown occurs.</xsl:text>
    <xsl:call-template name="PrintReturn" />
   </xsl:if>
   <xsl:if test="SERVICE_ACCEPT_PARAMCHANGE">
    <xsl:text>                 The service can reread its startup parameters without being stopped and restarted.</xsl:text>
    <xsl:call-template name="PrintReturn" />
   </xsl:if>
   <xsl:if test="SERVICE_ACCEPT_NETBINDCHANGE">
    <xsl:text>                 The service is a network component that can accept changes in its binding without being stopped and restarted.</xsl:text>
    <xsl:call-template name="PrintReturn" />
   </xsl:if>
   <xsl:if test="SERVICE_ACCEPT_HARDWAREPROFILECHANGE">
    <xsl:text>                 The service is notified when the computer's hardware profile has changed.</xsl:text>
    <xsl:call-template name="PrintReturn" />
   </xsl:if>
   <xsl:if test="SERVICE_ACCEPT_POWEREVENT">
    <xsl:text>                 The service is notified when the computer's power status has changed.</xsl:text>
    <xsl:call-template name="PrintReturn" />
   </xsl:if>
   <xsl:if test="SERVICE_ACCEPT_SESSIONCHANGE">
    <xsl:text>                 The service is notified when the computer's session status has changed.</xsl:text>
    <xsl:call-template name="PrintReturn" />
   </xsl:if>

  </xsl:template>

</xsl:transform>