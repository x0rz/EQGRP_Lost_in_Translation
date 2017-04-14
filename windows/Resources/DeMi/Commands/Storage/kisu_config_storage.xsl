<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageNodes">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="KiSuConfiguration">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Configuration</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">version</xsl:attribute>
				<xsl:value-of select="Version/@major"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="Version/@minor"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="Version/@fix"  />
				<xsl:text>.</xsl:text>
				<xsl:value-of select="Version/@build"/>
			</xsl:element>

			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Persistence</xsl:attribute>

				<xsl:element name="StringValue">
					<xsl:attribute name="name">Method</xsl:attribute>
					<xsl:value-of select="Persistence/@method"/>
				</xsl:element>
			</xsl:element>
			
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">KernelModuleLoader</xsl:attribute>

				<xsl:element name="StringValue">
					<xsl:attribute name="name">RegistryKey</xsl:attribute>
					<xsl:value-of select="KernelModuleLoader/RegKeyPath"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">RegistryValue</xsl:attribute>
					<xsl:value-of select="KernelModuleLoader/RegValueName"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">UserModuleLoader</xsl:attribute>

				<xsl:element name="StringValue">
					<xsl:attribute name="name">RegistryKey</xsl:attribute>
					<xsl:value-of select="UserModuleLoader/RegKeyPath"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">RegistryValue</xsl:attribute>
					<xsl:value-of select="UserModuleLoader/RegValueName"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">ModuleStoreDirectory</xsl:attribute>

				<xsl:element name="StringValue">
					<xsl:attribute name="name">RegistryKey</xsl:attribute>
					<xsl:value-of select="ModuleStoreDirectory/RegKeyPath"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">RegistryValue</xsl:attribute>
					<xsl:value-of select="ModuleStoreDirectory/RegValueName"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Launcher</xsl:attribute>

				<xsl:element name="StringValue">
					<xsl:attribute name="name">ServiceName</xsl:attribute>
					<xsl:value-of select="Launcher/ServiceName"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">RegistryValue</xsl:attribute>
					<xsl:value-of select="Launcher/RegValueName"/>
				</xsl:element>
			</xsl:element>
			<xsl:apply-templates select="Module"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="Module">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Module</xsl:attribute>

			<xsl:element name="IntValue">
				<xsl:attribute name="name">id</xsl:attribute>
				<xsl:value-of select="@id"/>
			</xsl:element>

			<xsl:element name="IntValue">
				<xsl:attribute name="name">order</xsl:attribute>
				<xsl:value-of select="@order"/>
			</xsl:element>

			<xsl:element name="IntValue">
				<xsl:attribute name="name">size</xsl:attribute>
				<xsl:value-of select="@size"/>
			</xsl:element>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">moduleName</xsl:attribute>
				<xsl:value-of select="@moduleName"/>
			</xsl:element>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">processName</xsl:attribute>
				<xsl:value-of select="@processName"/>
			</xsl:element>

			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Hash</xsl:attribute>

				<xsl:element name="StringValue">
					<xsl:attribute name="name">Md5</xsl:attribute>
					<xsl:value-of select="Md5Hash"/>
				</xsl:element>
				
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Sha1</xsl:attribute>
					<xsl:value-of select="Sha1Hash"/>
				</xsl:element>

			</xsl:element>

			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Flags</xsl:attribute>

				<xsl:element name="IntValue">
					<xsl:attribute name="name">value</xsl:attribute>
					<xsl:value-of select="@flags"/>
				</xsl:element>

				<xsl:call-template name="KiSu_Flag">
					<xsl:with-param name="flag" select="BOOT_START"/>
					<xsl:with-param name="var"  select="'BOOT_START'"/>
				</xsl:call-template>

				<xsl:call-template name="KiSu_Flag">
					<xsl:with-param name="flag" select="SYSTEM_START"/>
					<xsl:with-param name="var"  select="'SYSTEM_START'"/>
				</xsl:call-template>

				<xsl:call-template name="KiSu_Flag">
					<xsl:with-param name="flag" select="AUTO_START"/>
					<xsl:with-param name="var"  select="'AUTO_START'"/>
				</xsl:call-template>

				<xsl:call-template name="KiSu_Flag">
					<xsl:with-param name="flag" select="KERNEL_DRIVER"/>
					<xsl:with-param name="var"  select="'KERNEL_DRIVER'"/>
				</xsl:call-template>

				<xsl:call-template name="KiSu_Flag">
					<xsl:with-param name="flag" select="USER_MODE"/>
					<xsl:with-param name="var"  select="'USER_MODE'"/>
				</xsl:call-template>

				<xsl:call-template name="KiSu_Flag">
					<xsl:with-param name="flag" select="SYSTEM_MODE"/>
					<xsl:with-param name="var"  select="'SYSTEM_MODE'"/>
				</xsl:call-template>

				<xsl:call-template name="KiSu_Flag">
					<xsl:with-param name="flag" select="SERVICE_KEY"/>
					<xsl:with-param name="var"  select="'SERVICE_KEY'"/>
				</xsl:call-template>

				<xsl:call-template name="KiSu_Flag">
					<xsl:with-param name="flag" select="ENCRYPTED"/>
					<xsl:with-param name="var"  select="'ENCRYPTED'"/>
				</xsl:call-template>

				<xsl:call-template name="KiSu_Flag">
					<xsl:with-param name="flag" select="COMPRESSED"/>
					<xsl:with-param name="var"  select="'COMPRESSED'"/>
				</xsl:call-template>

				<xsl:call-template name="KiSu_Flag">
					<xsl:with-param name="flag" select="DEMAND_LOAD"/>
					<xsl:with-param name="var"  select="'DEMAND_LOAD'"/>
				</xsl:call-template>

				<xsl:call-template name="KiSu_Flag">
					<xsl:with-param name="flag" select="AUTO_START_ONCE"/>
					<xsl:with-param name="var"  select="'AUTO_START_ONCE'"/>
				</xsl:call-template>

			</xsl:element>

		</xsl:element>
	</xsl:template>

	<xsl:template name="KiSu_Flag">
		<xsl:param name="flag"/>
		<xsl:param name="var" />

		<xsl:element name="BoolValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="$flag">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

</xsl:transform>