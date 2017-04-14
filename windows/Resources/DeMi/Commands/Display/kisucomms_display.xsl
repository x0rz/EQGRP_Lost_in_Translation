<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransformsXml.xsl"/>

	<xsl:template match="KiSuModuleAdd">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>Sending </xsl:text>
				<xsl:value-of select="@chunkSize"/>
				<xsl:text> bytes.</xsl:text>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="KiSuAddedModule">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>Module </xsl:text>
				<xsl:value-of select="@moduleId"/>
				<xsl:text> added to instance </xsl:text>
				<xsl:value-of select="@instance"/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="KiSuCommsInitialized">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>Comms established to KISU instance </xsl:text>
				<xsl:value-of select="@id"/>
				<xsl:text> (</xsl:text>
				<xsl:value-of select="@name"/>
				<xsl:text>) version </xsl:text>
				<xsl:value-of select="@versionMajor"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="@versionMinor"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="@versionFix"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="@versionBuild"/>
				<xsl:call-template name="PrintReturn"/>
		</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="KiSuConfiguration">
		<xsl:if test="starts-with(@configValid, 'false')">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Warning'"/>
				<xsl:with-param name="text">
					<xsl:text>Configuration is not fully valid - be careful with this information.</xsl:text>
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>Version:  </xsl:text>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Good'"/>
			<xsl:with-param name="text">
				<xsl:value-of select="Version/@major"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="Version/@minor"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="Version/@fix"/>
				<xsl:text>.</xsl:text>
				<xsl:value-of select="Version/@build"/>
			</xsl:with-param>
		</xsl:call-template>
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:call-template name="PrintReturn" />
			</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="KernelModuleLoader">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:text>Kernel Module Loader:  </xsl:text>
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="Whitespace">
						<xsl:with-param name="i" select="'4'"/>
					</xsl:call-template>
					<xsl:text>Registry Key:    </xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Good'"/>
				<xsl:with-param name="text">
					<xsl:value-of select="KernelModuleLoader/RegKeyPath"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="Whitespace">
						<xsl:with-param name="i" select="'4'"/>
					</xsl:call-template>
					<xsl:text>Registry Value:  </xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Good'"/>
				<xsl:with-param name="text">
					<xsl:value-of select="KernelModuleLoader/RegValueName"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="UserModuleLoader">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:text>User Module Loader:  </xsl:text>
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="Whitespace">
						<xsl:with-param name="i" select="'4'"/>
					</xsl:call-template>
					<xsl:text>Registry Key:    </xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Good'"/>
				<xsl:with-param name="text">
					<xsl:value-of select="UserModuleLoader/RegKeyPath"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="Whitespace">
						<xsl:with-param name="i" select="'4'"/>
					</xsl:call-template>
					<xsl:text>Registry Value:  </xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Good'"/>
				<xsl:with-param name="text">
					<xsl:value-of select="UserModuleLoader/RegValueName"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="ModuleStoreDirectory">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:text>Module Store Directory:  </xsl:text>
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="Whitespace">
						<xsl:with-param name="i" select="'4'"/>
					</xsl:call-template>
					<xsl:text>Registry Key:    </xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Good'"/>
				<xsl:with-param name="text">
					<xsl:value-of select="ModuleStoreDirectory/RegKeyPath"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="Whitespace">
						<xsl:with-param name="i" select="'4'"/>
					</xsl:call-template>
					<xsl:text>Registry Value:  </xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Good'"/>
				<xsl:with-param name="text">
					<xsl:value-of select="ModuleStoreDirectory/RegValueName"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>

		</xsl:if>
		<xsl:if test="Launcher">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:text>Launcher:  </xsl:text>
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="Whitespace">
						<xsl:with-param name="i" select="'4'"/>
					</xsl:call-template>
					<xsl:text>Service Name:    </xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Good'"/>
				<xsl:with-param name="text">
					<xsl:value-of select="Launcher/ServiceName"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="Whitespace">
						<xsl:with-param name="i" select="'4'"/>
					</xsl:call-template>
					<xsl:text>Registry Value:  </xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="type" select="'Good'"/>
				<xsl:with-param name="text">
					<xsl:value-of select="Launcher/RegValueName"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="PrintReturn" />
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>

		<xsl:if test="Persistence">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:text>Persistence:  </xsl:text>
					<xsl:call-template name="PrintReturn" />
					<xsl:text>    Method:  </xsl:text>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:choose>
				<xsl:when test="Persistence/@method = 'UNKNOWN'">
					<xsl:call-template name="XmlOutput">
						<xsl:with-param name="type" select="'Warning'"/>
						<xsl:with-param name="text">
							<xsl:value-of select="Persistence/@method"/>
							<xsl:call-template name="PrintReturn" />
						</xsl:with-param>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="XmlOutput">
						<xsl:with-param name="type" select="'Good'"/>
						<xsl:with-param name="text">
							<xsl:value-of select="Persistence/@method"/>
							<xsl:call-template name="PrintReturn" />
						</xsl:with-param>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>

		<xsl:if test="Module">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:call-template name="PrintReturn"/>
					<xsl:text>Module Id         Size       Order      Flags            Name                   Process</xsl:text>
					<xsl:call-template name="PrintReturn"/>
					<xsl:text>===========================================================================================</xsl:text>
					<xsl:call-template name="PrintReturn"/>
				</xsl:with-param>
			</xsl:call-template>

		</xsl:if>
		<xsl:for-each select="Module">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:value-of select="@id"/>
					<xsl:text>  </xsl:text>
					<xsl:call-template name="Whitespace">
						<xsl:with-param name="i" select="10 - string-length(@size)"/>
					</xsl:call-template>
					<xsl:value-of select="@size"/>
					<xsl:text>  </xsl:text>
					<xsl:call-template name="Whitespace">
						<xsl:with-param name="i" select="10 - string-length(@order)"/>
					</xsl:call-template>
					<xsl:value-of select="@order"/>
					<xsl:text>  </xsl:text>
					<!-- flags - 10 spaces-->
					<xsl:call-template name="_flagDisplay">
						<xsl:with-param name="Element" select="BOOT_START" />
						<xsl:with-param name="Letter" select="'B'" />
					</xsl:call-template>
					<xsl:call-template name="_flagDisplay">
						<xsl:with-param name="Element" select="SYSTEM_START" />
						<xsl:with-param name="Letter" select="'S'" />
					</xsl:call-template>
					<xsl:call-template name="_flagDisplay">
						<xsl:with-param name="Element" select="AUTO_START" />
						<xsl:with-param name="Letter" select="'A'" />
					</xsl:call-template>
					<xsl:call-template name="_flagDisplay">
						<xsl:with-param name="Element" select="KERNEL_DRIVER" />
						<xsl:with-param name="Letter" select="'D'" />
					</xsl:call-template>
					<xsl:call-template name="_flagDisplay">
						<xsl:with-param name="Element" select="USER_MODE" />
						<xsl:with-param name="Letter" select="'U'" />
					</xsl:call-template>
					<xsl:call-template name="_flagDisplay">
						<xsl:with-param name="Element" select="SYSTEM_MODE" />
						<xsl:with-param name="Letter" select="'R'" />
					</xsl:call-template>
					<xsl:call-template name="_flagDisplay">
						<xsl:with-param name="Element" select="SERVICE_KEY" />
						<xsl:with-param name="Letter" select="'K'" />
					</xsl:call-template>
					<xsl:call-template name="_flagDisplay">
						<xsl:with-param name="Element" select="ENCRYPTED" />
						<xsl:with-param name="Letter" select="'E'" />
					</xsl:call-template>
					<xsl:call-template name="_flagDisplay">
						<xsl:with-param name="Element" select="COMPRESSED" />
						<xsl:with-param name="Letter" select="'C'" />
					</xsl:call-template>
					<xsl:call-template name="_flagDisplay">
						<xsl:with-param name="Element" select="DEMAND_LOAD" />
						<xsl:with-param name="Letter" select="'L'" />
					</xsl:call-template>
					<xsl:call-template name="_flagDisplay">
						<xsl:with-param name="Element" select="AUTO_START_ONCE" />
						<xsl:with-param name="Letter" select="'O'" />
					</xsl:call-template>

					<xsl:text>  </xsl:text>
					<xsl:call-template name="_printModuleName"/>
					<xsl:text>  </xsl:text>
					<xsl:value-of select="@processName"/>
					<xsl:call-template name="PrintReturn"/>
					<xsl:if test="Md5Hash">
						<xsl:text>    Md5  : </xsl:text>
						<xsl:value-of select="Md5Hash"/>
						<xsl:call-template name="PrintReturn"/>
					</xsl:if>
					
					<xsl:if test="Sha1Hash">
						<xsl:text>    Sha1 : </xsl:text>
						<xsl:value-of select="Sha1Hash"/>
						<xsl:call-template name="PrintReturn"/>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:for-each>
		<xsl:if test="Module">
			<xsl:call-template name="XmlOutput">
				<xsl:with-param name="text">
					<xsl:text>    B: BootStart,  S: SystemStart, A: AutoStart,      D: KernelDriver</xsl:text><xsl:call-template name="PrintReturn"/>
					<xsl:text>    U: UserMode,   R: SystemMode,  K: ServiceKey,     E: Encrypted</xsl:text><xsl:call-template name="PrintReturn"/>
					<xsl:text>    C: Compressed, L: DemandLoad,  O: AutoStart Once</xsl:text><xsl:call-template name="PrintReturn"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="KiSuDeletedModule">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>Module </xsl:text>
				<xsl:value-of select="@moduleId"/>
				<xsl:text> deleted from instance </xsl:text>
				<xsl:value-of select="@instance"/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="KiSuDriverLoad">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>Driver </xsl:text>
				<xsl:value-of select="@moduleId"/>
				<xsl:text> loaded from instance </xsl:text>
				<xsl:value-of select="@instance"/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="KiSuDriverUnload">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>Driver </xsl:text>
				<xsl:value-of select="@moduleId"/>
				<xsl:text> unloaded from instance </xsl:text>
				<xsl:value-of select="@instance"/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="KiSuEnumeration">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>   Id         Version    Name</xsl:text>
				<xsl:call-template name="PrintReturn"/>
				<xsl:call-template name="CharFill">
					<xsl:with-param name="i" select="'32'"/>
					<xsl:with-param name="char" select="'='"/>
				</xsl:call-template>
				<xsl:call-template name="PrintReturn"/>
				<xsl:for-each select="KiSu">
					<xsl:value-of select="@id"/>
					
					<xsl:call-template name="Whitespace">
						<xsl:with-param name="i" select="'4'"/>
					</xsl:call-template>
					
					<xsl:value-of select="@versionMajor"/>
					<xsl:text>.</xsl:text>
					<xsl:value-of select="@versionMinor"/>
					<xsl:text>.</xsl:text>
					<xsl:value-of select="@versionFix"/>
					<xsl:text>.</xsl:text>
					<xsl:value-of select="@versionBuild"/>

					<xsl:call-template name="Whitespace">
						<xsl:with-param name="i" select="'4'"/>
					</xsl:call-template>

					<xsl:value-of select="@name"/>
					<xsl:call-template name="PrintReturn"/>
				</xsl:for-each>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="KiSuModuleFree">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>Module </xsl:text>
				<xsl:value-of select="@moduleHandle"/>
				<xsl:text> unloaded for instance </xsl:text>
				<xsl:value-of select="@instance"/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="KiSuModuleLoad">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>Module </xsl:text>
				<xsl:value-of select="@moduleId"/>
				<xsl:text> loaded at </xsl:text>
				<xsl:value-of select="@moduleHandle"/>
				<xsl:text> from instance </xsl:text>
				<xsl:value-of select="@instance"/>
				<xsl:call-template name="PrintReturn"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="KiSuProcessLoad">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="text">
				<xsl:text>Modules loaded into process </xsl:text>
				<xsl:value-of select="@processId"/>
				<xsl:text> from instance </xsl:text>
				<xsl:value-of select="@instance"/>
				<xsl:call-template name="PrintReturn" />
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="KiSuReadModuleSuccess">
		<xsl:call-template name="XmlOutput">
			<xsl:with-param name="type" select="'Good'"/>
			<xsl:with-param name="text">
				<xsl:text>Read successful (</xsl:text>
				<xsl:value-of select="@bytes"/>
				<xsl:text> bytes)</xsl:text>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="_printModuleName">
		<xsl:variable name="modName">
			<xsl:choose>
				<xsl:when test="string-length(@moduleName) &gt; 0">
					<xsl:value-of select="@moduleName"/>
				</xsl:when>
				<xsl:when test="@id = '0xab3f907f'">
					<xsl:text>UserModuleLoader 64-Bit</xsl:text>
				</xsl:when>
				<xsl:when test="@id = '0xbb397f32'">
					<xsl:text>UserModuleLoader 32-Bit</xsl:text>
				</xsl:when>
				<xsl:when test="@id = '0xbb397f34'">
					<xsl:text>Persistence Identifier</xsl:text>
				</xsl:when>
				<xsl:when test="@id = '0xbb397f33'">
					<xsl:text>BH</xsl:text>
				</xsl:when>
				<xsl:when test="@id = '0xbb397f35'">
					<xsl:text>LoadModuleHelperDll</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="$modName"/>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="30 - string-length($modName)"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="_flagDisplay">
		<xsl:param name="Element"/>
		<xsl:param name="Letter"/>

		<xsl:choose>
			<xsl:when test="$Element">
				<xsl:value-of select="$Letter"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:transform>