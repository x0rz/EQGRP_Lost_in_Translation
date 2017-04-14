<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes"/>
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Services/Service"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Service">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Service</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ServiceName</xsl:attribute>
				<xsl:value-of select="@serviceName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">DisplayName</xsl:attribute>
				<xsl:value-of select="@displayName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">State</xsl:attribute>
				<xsl:value-of select="State"/>
			</xsl:element>
			<xsl:apply-templates select="ServiceType"/>
			<xsl:apply-templates select="AcceptedCodes"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="ServiceType">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ServiceType</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">value</xsl:attribute>
				<xsl:value-of select="@value"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">serviceOwnProcess</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SERVICE_WIN32_OWN_PROCESS">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">serviceSharesProcess</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SERVICE_WIN32_SHARE_PROCESS">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">serviceDeviceDriver</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SERVICE_KERNEL_DRIVER">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">serviceFileSystemDriver</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SERVICE_FILE_SYSTEM_DRIVER">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">serviceInteractiveProcess</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SERVICE_INTERACTIVE_PROCESS">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>				
		</xsl:element>
	</xsl:template>

	<xsl:template match="AcceptedCodes">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">AcceptedCodes</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">value</xsl:attribute>
				<xsl:value-of select="@value"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">acceptsStop</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SERVICE_ACCEPT_STOP">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">acceptsPauseContinue</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SERVICE_ACCEPT_PAUSE_CONTINUE">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">acceptsShutdown</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SERVICE_ACCEPT_SHUTDOWN">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">acceptsParamChange</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SERVICE_ACCEPT_PARAMCHANGE">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">acceptsNetBindChange</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SERVICE_ACCEPT_NETBINDCHANGE">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>	
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">acceptsHardwareProfChange</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SERVICE_ACCEPT_HARDWAREPROFILECHANGE">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">acceptsPowerEvent</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SERVICE_ACCEPT_POWEREVENT">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">acceptsSessionChange</xsl:attribute>
				<xsl:choose>
					<xsl:when test="SERVICE_ACCEPT_SESSIONCHANGE">
						<xsl:text>true</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>false</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>								
		</xsl:element>
	</xsl:template>
</xsl:transform>