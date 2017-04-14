<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl"/>
  	
	<xsl:template match="GrDo_ProcessScanner">
	   <xsl:apply-templates select="GrDoHiddenProcessList"/>
	   <xsl:apply-templates select="GrDoProcessModuleList"/>
	   <xsl:apply-templates select="GrDoProcessModulePEDataList"/>
	   <xsl:apply-templates select="GrDoInjectedProcessReadErrorList"/>
	   <xsl:apply-templates select="GrDoProcessMemoryList"/>
   
	</xsl:template>
	
	<xsl:template match="GrDoHiddenProcessList">
	   <xsl:apply-templates select="GrDoHiddenProcess"/>
	</xsl:template>
	
	<xsl:template match="GrDoProcessModuleList">
	   <xsl:apply-templates select="GrDoProcessModule"/>
	</xsl:template>

	<xsl:template match="GrDoProcessModulePEDataList">
	   <xsl:apply-templates select="GrDoProcessModulePEData"/>
	</xsl:template>

	<xsl:template match="GrDoInjectedProcessReadErrorList">
	   <xsl:apply-templates select="GrDoInjectedProcessReadError"/>
	</xsl:template>
	
	<xsl:template match="GrDoProcessMemoryList">
	   <xsl:apply-templates select="GrDoProcessMemory"/>
	</xsl:template>

	<xsl:template match="GrDoProcessMemory">
		<xsl:text>Memory from Process ID:      </xsl:text>
		<xsl:value-of select="@ProcessPID" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   BaseAddress:        </xsl:text>
		<xsl:value-of select="@BaseAddress" />
		<xsl:if test="(number(@BaseAddressMZ) > 0)">
			<xsl:text> (possible MZ header found)</xsl:text>
		</xsl:if>		
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   State:              </xsl:text>
		<xsl:value-of select="@State" />
		<xsl:call-template name="MemoryProtect">
		   <xsl:with-param name="memval" select="@State"/>
		</xsl:call-template> 
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   Protect:            </xsl:text>
		<xsl:value-of select="@Protect" />
		<xsl:call-template name="MemoryProtect">
		   <xsl:with-param name="memval" select="@Protect"/>
		</xsl:call-template> 		
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   Type:               </xsl:text>
		<xsl:value-of select="@Type" />
		<xsl:call-template name="MemoryProtect">
		   <xsl:with-param name="memval" select="@Type"/>
		</xsl:call-template> 		
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   AllocationBase:     </xsl:text>
		<xsl:value-of select="@AllocationBase" />
		<xsl:if test="(number(@AllocationBaseMZ) > 0)">
			<xsl:text> (possible MZ header found)</xsl:text>
		</xsl:if>	
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   AllocationProtect:  </xsl:text>
		<xsl:value-of select="@AllocationProtect" />
		<xsl:call-template name="MemoryProtect">
		   <xsl:with-param name="memval" select="@AllocationProtect"/>
		</xsl:call-template> 
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   RegionSize:         </xsl:text>
		<xsl:value-of select="@RegionSize" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   SectionName:        </xsl:text>
		<xsl:value-of select="@SectionName" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   MappedFileName:     </xsl:text>
		<xsl:value-of select="@MappedFileName" />
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintReturn" />
		
	
	</xsl:template>
	
	
	<xsl:template match="GrDoProcessModulePEData">
		
		<xsl:text>Process ID:      </xsl:text>
		<xsl:value-of select="@ProcessPID" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   Module Name:              </xsl:text>
		<xsl:value-of select="@ModuleName" />
		<xsl:call-template name="PrintReturn" />
		<xsl:choose>
			<xsl:when test="(1 = number(@Is64))">
				<xsl:text>   Arch:                     x64</xsl:text>
				<xsl:call-template name="PrintReturn" />
			</xsl:when>
		</xsl:choose>
		<xsl:text>   Linker Time/Version:      </xsl:text>
		<xsl:value-of select="substring-before(LinkerTime, 'T')"/>
		<xsl:text>  Major: </xsl:text>
		<xsl:value-of select="@MajorLinkerVersion" />
		<xsl:text>  Minor: </xsl:text>
		<xsl:value-of select="@MinorLinkerVersion" />
		<xsl:choose>
			<xsl:when test="(4 = number(@MajorLinkerVersion)) and (0 = number(@MinorLinkerVersion))">
				<xsl:text> --Visual Studio (original)</xsl:text>
			</xsl:when>
			<xsl:when test="(5 = number(@MajorLinkerVersion)) and (0 = number(@MinorLinkerVersion))">
				<xsl:text> --Visual Studio 97</xsl:text>
			</xsl:when>
			<xsl:when test="(6 = number(@MajorLinkerVersion)) and (0 = number(@MinorLinkerVersion))">
						<xsl:text> --Visual Studio 6</xsl:text>
			</xsl:when>
			<xsl:when test="(7 = number(@MajorLinkerVersion))">
				<xsl:choose>
					<xsl:when test="(0 = number(@MinorLinkerVersion))">
						<xsl:text> --Visual Studio 2003</xsl:text>
					</xsl:when>
					<xsl:when test="(10 = number(@MinorLinkerVersion))">
						<xsl:text> --Visual Studio 2003 .NET</xsl:text>
					</xsl:when>
				</xsl:choose>	
			</xsl:when>
			<xsl:when test="(8 = number(@MajorLinkerVersion)) and (0 = number(@MinorLinkerVersion))">
						<xsl:text> --Visual Studio 2005</xsl:text>
			</xsl:when>
			<xsl:when test="(9 = number(@MajorLinkerVersion)) and (0 = number(@MinorLinkerVersion))">
						<xsl:text> --Visual Studio 2008</xsl:text>
			</xsl:when>
			<xsl:when test="(10 = number(@MajorLinkerVersion)) and (0 = number(@MinorLinkerVersion))">
						<xsl:text> --Visual Studio 2010</xsl:text>
			</xsl:when>
			
		</xsl:choose>	
		
		<xsl:call-template name="PrintReturn" />
		
	

		<xsl:text>   base address:             </xsl:text>
		<xsl:value-of select="@baseAddress" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   image size:               </xsl:text>
		<xsl:value-of select="@imageSize" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   Linker Version:           </xsl:text>
		<xsl:value-of select="@dwLinkerVersion" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   PE Checksum:              </xsl:text>
		<xsl:value-of select="@dwEmbeddedChecksum" />
		<xsl:call-template name="PrintReturn" />

		<xsl:text>   Export Name:              </xsl:text>
		<xsl:value-of select="@DllExportName" />
		<xsl:call-template name="PrintReturn" />		
		<xsl:text>   ExportCount:              </xsl:text>
		<xsl:value-of select="@dwExportCount" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   ExportLinkerTimeStamp:    </xsl:text>
		<xsl:value-of select="substring-before(ExportTime, 'T')"/>
		<xsl:call-template name="PrintReturn" />
			<xsl:if test="(number(@FilePEMatch) > 0)">
			<xsl:text>   Compare to file on disk:  </xsl:text>
			<xsl:choose>
				<xsl:when test="(1 = number(@FilePEMatch))">
					<xsl:text>MATCH</xsl:text>
				</xsl:when>
				<xsl:when test="(2 = number(@FilePEMatch))">
					<xsl:text>file not found</xsl:text>
				</xsl:when>
				<xsl:when test="(3 = number(@FilePEMatch))">
					<xsl:text>file read error</xsl:text>
				</xsl:when>
				<xsl:when test="(4 = number(@FilePEMatch))">
					<xsl:text>Invalid PE</xsl:text>
				</xsl:when>
				<xsl:when test="(5 = number(@FilePEMatch))">
					<xsl:text>PE mismatch</xsl:text>
				</xsl:when>
				<xsl:when test="(6 = number(@FilePEMatch))">
					<xsl:text>PE section mismatch</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>UNKNOWN_ERROR</xsl:text>
				</xsl:otherwise>

			</xsl:choose>	
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
		<xsl:choose>
			<xsl:when test="GrDoProcessPEData">
				<xsl:apply-templates select="GrDoProcessPEData"/>
			</xsl:when>			
		</xsl:choose>
			
	</xsl:template>
	
	<xsl:template match="GrDoProcessModule">
		
		<xsl:text>Process ID:      </xsl:text>
		<xsl:value-of select="@ProcessPID" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   Module Name:  </xsl:text>
		<xsl:value-of select="@ModuleName" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   base address: </xsl:text>
		<xsl:value-of select="@baseAddress" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   image size:   </xsl:text>
		<xsl:value-of select="@imageSize" />
		<xsl:call-template name="PrintReturn" />
		
			
	</xsl:template>
	
	
	
		
	<xsl:template match="GrDoHiddenProcess">
		<xsl:if test="(number(@ProcessPID) > 0)">
			<xsl:text>Found hidden process PID </xsl:text>
			<xsl:value-of select="@ProcessPID" />
			<xsl:text> created </xsl:text>
			<xsl:value-of select="substring-before(ProcessCreateTime, 'T')"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="substring(substring-after(ProcessCreateTime, 'T'),0,9)"/>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
		<xsl:if test="(number(@ProcessPID) = 0)">
			<xsl:text>No hidden processes found </xsl:text>
			<xsl:call-template name="PrintReturn" />
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="GrDoInjectedProcessReadError">
		<xsl:text>Unable to open modules for process ID </xsl:text>
		<xsl:value-of select="@ProcessPID" />
		<xsl:text>   </xsl:text>
		<xsl:value-of select="@ProcessName" />
		<xsl:call-template name="PrintReturn" />
		
	</xsl:template>
		
	<xsl:template name="MemoryProtect">
		<xsl:param name="memval"/>
		<xsl:choose>
			<xsl:when test="('0x00000001' = $memval)">
				<xsl:text>(PAGE_NOACCESS)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00000002' = $memval)">
				<xsl:text>(PAGE_READONLY)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00000004' = $memval)">
				<xsl:text>(PAGE_READWRITE)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00000008' = $memval)">
				<xsl:text>(PAGE_WRITECOPY)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00000010' = $memval)">
				<xsl:text>(PAGE_EXECUTE)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00000020' = $memval)">
				<xsl:text>(PAGE_EXECUTE_READ)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00000040' = $memval)">
				<xsl:text>(PAGE_EXECUTE_READWRITE)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00000080' = $memval)">
				<xsl:text>(PAGE_EXECUTE_WRITECOPY)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00000100' = $memval)">
				<xsl:text>(PAGE_GUARD)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00000200' = $memval)">
				<xsl:text>(PAGE_NOCACHE)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00000400' = $memval)">
				<xsl:text>(PAGE_WRITECOMBINE)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00001000' = $memval)">
				<xsl:text>(MEM_COMMIT)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00002000' = $memval)">
				<xsl:text>(MEM_RESERVE)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00004000' = $memval)">
				<xsl:text>(MEM_DECOMMIT)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00008000' = $memval)">
				<xsl:text>(MEM_RELEASE)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00010000' = $memval)">
				<xsl:text>(MEM_FREE)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00020000' = $memval)">
				<xsl:text>(MEM_PRIVATE)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00040000' = $memval)">
				<xsl:text>(MEM_MAPPED)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00080000' = $memval)">
				<xsl:text>(MEM_RESET)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00100000' = $memval)">
				<xsl:text>(MEM_TOP_DOWN)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00200000' = $memval)">
				<xsl:text>(MEM_WRITE_WATCH)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00400000' = $memval)">
				<xsl:text>(MEM_PHYSICAL)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x00800000' = $memval)">
				<xsl:text>(MEM_ROTATE)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x20000000' = $memval)">
				<xsl:text>(MEM_LARGE_PAGES)</xsl:text>
			</xsl:when>
			<xsl:when test="('0x80000000' = $memval)">
				<xsl:text>(MEM_4MB_PAGES)</xsl:text>
			</xsl:when>
		</xsl:choose>	
	</xsl:template>
	

	<xsl:template match="GrDoProcessPEData">
		<xsl:call-template name="PrintReturn" />
		<xsl:text>   PE header data</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    Dos magic                      : </xsl:text>
		<xsl:value-of select="@Dos_magic" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    Dos_lfanew                     : </xsl:text>
		<xsl:value-of select="@Dos_lfanew" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_Machine                     : </xsl:text>
		<xsl:value-of select="@NT_Machine" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_NumberofSections            : </xsl:text>
		<xsl:value-of select="@NT_NumberofSections" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_TimeDateStamp               : </xsl:text>
		<xsl:value-of select="@NT_TimeDateStamp" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_NumberofSymbols             : </xsl:text>
		<xsl:value-of select="@NT_NumberofSymbols" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfOptionalHeader        : </xsl:text>
		<xsl:value-of select="@NT_SizeOfOptionalHeader" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_Characteristics             : </xsl:text>
		<xsl:value-of select="@NT_Characteristics" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_Magic                       : </xsl:text>
		<xsl:value-of select="@NT_Magic" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_MajorLinkerVersion          : </xsl:text>
		<xsl:value-of select="@NT_MajorLinkerVersion" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_MinorLinkerVersion          : </xsl:text>
		<xsl:value-of select="@NT_MinorLinkerVersion" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfCode                  : </xsl:text>
		<xsl:value-of select="@NT_SizeOfCode" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfInitializedData       : </xsl:text>
		<xsl:value-of select="@NT_SizeOfInitializedData" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfUninitializedData     : </xsl:text>
		<xsl:value-of select="@NT_SizeOfUninitializedData" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_AddressOfEntryPoint         : </xsl:text>
		<xsl:value-of select="@NT_AddressOfEntryPoint" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_BaseOfCode                  : </xsl:text>
		<xsl:value-of select="@NT_BaseOfCode" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_BaseOfData                  : </xsl:text>
		<xsl:value-of select="@NT_BaseOfData" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_ImageBase                   : </xsl:text>
		<xsl:value-of select="@NT_ImageBase" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SectionAlignment            : </xsl:text>
		<xsl:value-of select="@NT_SectionAlignment" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_FileAlignment               : </xsl:text>
		<xsl:value-of select="@NT_FileAlignment" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_MajorOperatingSystemVersion : </xsl:text>
		<xsl:value-of select="@NT_MajorOperatingSystemVersion" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_MinorOperatingSystemVersion : </xsl:text>
		<xsl:value-of select="@NT_MinorOperatingSystemVersion" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_MajorImageVersion           : </xsl:text>
		<xsl:value-of select="@NT_MajorImageVersion" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_MinorImageVersion           : </xsl:text>
		<xsl:value-of select="@NT_MinorImageVersion" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_MajorSubsystemVersion       : </xsl:text>
		<xsl:value-of select="@NT_MajorSubsystemVersion" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_MinorSubsystemVersion       : </xsl:text>
		<xsl:value-of select="@NT_MinorSubsystemVersion" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_Win32VersionValue           : </xsl:text>
		<xsl:value-of select="@NT_Win32VersionValue" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfImage                 : </xsl:text>
		<xsl:value-of select="@NT_SizeOfImage" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfHeaders               : </xsl:text>
		<xsl:value-of select="@NT_SizeOfHeaders" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_CheckSum                    : </xsl:text>
		<xsl:value-of select="@NT_CheckSum" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_Subsystem                   : </xsl:text>
		<xsl:value-of select="@NT_Subsystem" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_DllCharacteristics          : </xsl:text>
		<xsl:value-of select="@NT_DllCharacteristics" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfStackReserve          : </xsl:text>
		<xsl:value-of select="@NT_SizeOfStackReserve" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfStackCommit           : </xsl:text>
		<xsl:value-of select="@NT_SizeOfStackCommit" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfHeapReserve           : </xsl:text>
		<xsl:value-of select="@NT_SizeOfHeapReserve" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_SizeOfHeapCommit            : </xsl:text>
		<xsl:value-of select="@NT_SizeOfHeapCommit" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_LoaderFlags                 : </xsl:text>
		<xsl:value-of select="@NT_LoaderFlags" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>    NT_NumberOfRvaAndSizes         : </xsl:text>
		<xsl:value-of select="@NT_NumberOfRvaAndSizes" />
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>     Sections         Name          SizeofRawData   VirtualAddress  Characteristics</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>     ----------------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:apply-templates select="GrDoPESection"/>
		
		<xsl:call-template name="PrintReturn" />

	</xsl:template>
	
	<xsl:template match="GrDoPESection">
		<xsl:text>                     </xsl:text>
		<xsl:value-of select="@SectionName" />
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="15 - string-length(@SectionName)"/>
		</xsl:call-template>
		<xsl:value-of select="@SizeofRawData" />
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="16 - string-length(@SizeofRawData)"/>
		</xsl:call-template>
		<xsl:value-of select="@VirtualAddress" />
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="16 - string-length(@VirtualAddress)"/>
		</xsl:call-template>
		<xsl:value-of select="@Characteristics" />
		
		<xsl:call-template name="PrintReturn" />

	</xsl:template>
	
</xsl:transform>