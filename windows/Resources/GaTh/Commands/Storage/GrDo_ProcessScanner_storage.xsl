<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name = "StorageObjects">
			<xsl:apply-templates select = "GrDo_ProcessScanner"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="GrDo_ProcessScanner">
		<xsl:apply-templates select="GrDoHiddenProcessList" />
		<xsl:apply-templates select="GrDoProcessModuleList" />
		<xsl:apply-templates select="GrDoInjectedProcessReadErrorList" />
		<xsl:apply-templates select="GrDoProcessModulePEDataList" />
		<xsl:apply-templates select="GrDoProcessMemoryList" />
	</xsl:template>

	<xsl:template match="GrDoHiddenProcessList">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">HiddenProcessList</xsl:attribute>
			<xsl:apply-templates select="GrDoHiddenProcess" />
		</xsl:element>	
	</xsl:template>
	
	<xsl:template match="GrDoProcessModuleList">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ProcessModuleList</xsl:attribute>
			<xsl:apply-templates select="GrDoProcessModule" />
		</xsl:element>	
	</xsl:template>
	
	<xsl:template match="GrDoInjectedProcessReadErrorList">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ProcessReadErrorList</xsl:attribute>
			<xsl:apply-templates select="GrDoInjectedProcessReadError" />
		</xsl:element>	
	</xsl:template>
	
	<xsl:template match="GrDoProcessModulePEDataList">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ProcessModulePEDataList</xsl:attribute>
			<xsl:apply-templates select="GrDoProcessModulePEData" />
		</xsl:element>	
	</xsl:template>
	
	<xsl:template match="GrDoProcessMemoryList">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ProcessMemoryList</xsl:attribute>
			<xsl:apply-templates select="GrDoProcessMemory" />
		</xsl:element>	
	</xsl:template>
	
	
	<xsl:template match="GrDoProcessMemory">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ProcessMemory</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ProcessPID</xsl:attribute>
				<xsl:value-of select="@ProcessPID" />
			</xsl:element>			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">BaseAddress</xsl:attribute>
				<xsl:value-of select="@BaseAddress" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">AllocationBase</xsl:attribute>
				<xsl:value-of select="@AllocationBase" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">AllocationProtect</xsl:attribute>
				<xsl:value-of select="@AllocationProtect" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">RegionSize</xsl:attribute>
				<xsl:value-of select="@RegionSize" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">State</xsl:attribute>
				<xsl:value-of select="@State" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Protect</xsl:attribute>
				<xsl:value-of select="@Protect" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Type</xsl:attribute>
				<xsl:value-of select="@Type" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">AllocationBaseMZ</xsl:attribute>
				<xsl:value-of select="@AllocationBaseMZ" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">BaseAddressMZ</xsl:attribute>
				<xsl:value-of select="@BaseAddressMZ" />
			</xsl:element>		
			<xsl:element name="StringValue">
				<xsl:attribute name="name">SectionName</xsl:attribute>
				<xsl:value-of select="@SectionName" />
			</xsl:element>		
			<xsl:element name="StringValue">
				<xsl:attribute name="name">MappedFileName</xsl:attribute>
				<xsl:value-of select="@MappedFileName" />
			</xsl:element>		
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="GrDoProcessModulePEData">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ModulePEData</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ProcessPID</xsl:attribute>
				<xsl:value-of select="@ProcessPID" />
			</xsl:element>			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ModuleName</xsl:attribute>
				<xsl:value-of select="@ModuleName" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">baseAddress</xsl:attribute>
				<xsl:value-of select="@baseAddress" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">imageSize</xsl:attribute>
				<xsl:value-of select="@imageSize" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">dwLinkerVersion</xsl:attribute>
				<xsl:value-of select="@dwLinkerVersion" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">dwEmbeddedChecksum</xsl:attribute>
				<xsl:value-of select="@dwEmbeddedChecksum" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Is64</xsl:attribute>
				<xsl:value-of select="@Is64" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">MajorLinkerVersion</xsl:attribute>
				<xsl:value-of select="@MajorLinkerVersion" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">MinorLinkerVersion</xsl:attribute>
				<xsl:value-of select="@MinorLinkerVersion" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">dwExportCount</xsl:attribute>
				<xsl:value-of select="@dwExportCount" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">dwLinkerTimeStamp</xsl:attribute>
				<xsl:value-of select="@dwLinkerTimeStamp" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">dwExportLinkerTimeStamp</xsl:attribute>
				<xsl:value-of select="@dwExportLinkerTimeStamp" />
			</xsl:element>	
			<xsl:element name="IntValue">
				<xsl:attribute name="name">FilePEMatch</xsl:attribute>
				<xsl:value-of select="@FilePEMatch" />
			</xsl:element>	
			<xsl:element name="StringValue">
				<xsl:attribute name="name">DllExportName</xsl:attribute>
				<xsl:value-of select="@DllExportName" />
			</xsl:element>					
			<xsl:call-template name="FileTimeFunction">
				<xsl:with-param name="time" select="LinkerTime"/>
				<xsl:with-param name="var"  select="'LinkerTime'"/>
			</xsl:call-template>	
			<xsl:call-template name="FileTimeFunction">
				<xsl:with-param name="time" select="ExportTime"/>
				<xsl:with-param name="var"  select="'ExportTime'"/>
			</xsl:call-template>	
			<xsl:apply-templates select="GrDoProcessPEData" />
		</xsl:element>
		
	</xsl:template>
	
	<xsl:template match="GrDoProcessModule">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ProcessModule</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ProcessPID</xsl:attribute>
				<xsl:value-of select="@ProcessPID" />
			</xsl:element>			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ModuleName</xsl:attribute>
				<xsl:value-of select="@ModuleName" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">baseAddress</xsl:attribute>
				<xsl:value-of select="@baseAddress" />
			</xsl:element>		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">imageSize</xsl:attribute>
				<xsl:value-of select="@imageSize" />
			</xsl:element>		
		</xsl:element>
	</xsl:template>

	<xsl:template match="GrDoInjectedProcessReadError">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ProcessReadError</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ProcessPID</xsl:attribute>
				<xsl:value-of select="@ProcessPID" />
			</xsl:element>		
			<xsl:element name="StringValue">
				<xsl:attribute name="name">ProcessName</xsl:attribute>
				<xsl:value-of select="@ProcessName" />
			</xsl:element>						
		</xsl:element>
	</xsl:template>
	
	
	<xsl:template match="GrDoHiddenProcess">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">HiddenProcess</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">ProcessPID</xsl:attribute>
				<xsl:value-of select="@ProcessPID" />
			</xsl:element>			
			<xsl:call-template name="FileTimeFunction">
					<xsl:with-param name="time" select="ProcessCreateTime"/>
					<xsl:with-param name="var"  select="'ProcessCreateTime'"/>
			</xsl:call-template>	
			
		</xsl:element>
	</xsl:template>
	
		
	<xsl:template name="FileTimeFunction">
		<xsl:param name="time"/>
		<xsl:param name="var" />
		
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var"/>
			</xsl:attribute>
			
			<xsl:element name="StringValue">
				<xsl:attribute name="name">time</xsl:attribute>
				<xsl:value-of select="$time"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="$time/@type"/>
			</xsl:element>
		</xsl:element>
		
		
	</xsl:template>
	
	<xsl:template match="GrDoPESection">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">PESection</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">SectionName</xsl:attribute>
				<xsl:value-of select="@SectionName" />
			</xsl:element>			
			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Characteristics</xsl:attribute>
				<xsl:value-of select="@Characteristics" />
			</xsl:element>			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">SizeofRawData</xsl:attribute>
				<xsl:value-of select="@SizeofRawData" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">VirtualAddress</xsl:attribute>
				<xsl:value-of select="@VirtualAddress" />
			</xsl:element>
			
		</xsl:element>
	</xsl:template>
	
	
	<xsl:template match="GrDoProcessPEData">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">GrDoPEInformation</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Dos_magic</xsl:attribute>
				<xsl:value-of select="@Dos_magic" />
			</xsl:element>			
			<xsl:element name="IntValue">
				<xsl:attribute name="name">Dos_lfanew</xsl:attribute>
				<xsl:value-of select="@Dos_lfanew" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_Machine</xsl:attribute>
				<xsl:value-of select="@NT_Machine" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_NumberofSections</xsl:attribute>
				<xsl:value-of select="@NT_NumberofSections" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_TimeDateStamp</xsl:attribute>
				<xsl:value-of select="@NT_TimeDateStamp" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_NumberofSymbols</xsl:attribute>
				<xsl:value-of select="@NT_NumberofSymbols" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfOptionalHeader</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfOptionalHeader" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_Characteristics</xsl:attribute>
				<xsl:value-of select="@NT_Characteristics" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_Magic</xsl:attribute>
				<xsl:value-of select="@NT_Magic" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_MajorLinkerVersion</xsl:attribute>
				<xsl:value-of select="@NT_MajorLinkerVersion" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_MinorLinkerVersion</xsl:attribute>
				<xsl:value-of select="@NT_MinorLinkerVersion" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfCode</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfCode" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfInitializedData</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfInitializedData" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfUninitializedData</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfUninitializedData" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_AddressOfEntryPoint</xsl:attribute>
				<xsl:value-of select="@NT_AddressOfEntryPoint" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_BaseOfCode</xsl:attribute>
				<xsl:value-of select="@NT_BaseOfCode" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_BaseOfData</xsl:attribute>
				<xsl:value-of select="@NT_BaseOfData" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_ImageBase</xsl:attribute>
				<xsl:value-of select="@NT_ImageBase" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SectionAlignment</xsl:attribute>
				<xsl:value-of select="@NT_SectionAlignment" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_FileAlignment</xsl:attribute>
				<xsl:value-of select="@NT_FileAlignment" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_MajorOperatingSystemVersion</xsl:attribute>
				<xsl:value-of select="@NT_MajorOperatingSystemVersion" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_MinorOperatingSystemVersion</xsl:attribute>
				<xsl:value-of select="@NT_MinorOperatingSystemVersion" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_MajorImageVersion</xsl:attribute>
				<xsl:value-of select="@NT_MajorImageVersion" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_MinorImageVersion</xsl:attribute>
				<xsl:value-of select="@NT_MinorImageVersion" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_MajorSubsystemVersion</xsl:attribute>
				<xsl:value-of select="@NT_MajorSubsystemVersion" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_MinorSubsystemVersion</xsl:attribute>
				<xsl:value-of select="@NT_MinorSubsystemVersion" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_Win32VersionValue</xsl:attribute>
				<xsl:value-of select="@NT_Win32VersionValue" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfImage</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfImage" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfHeaders</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfHeaders" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_CheckSum</xsl:attribute>
				<xsl:value-of select="@NT_CheckSum" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_Subsystem</xsl:attribute>
				<xsl:value-of select="@NT_Subsystem" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_DllCharacteristics</xsl:attribute>
				<xsl:value-of select="@NT_DllCharacteristics" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfStackReserve</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfStackReserve" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfStackCommit</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfStackCommit" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfHeapReserve</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfHeapReserve" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_SizeOfHeapCommit</xsl:attribute>
				<xsl:value-of select="@NT_SizeOfHeapCommit" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_LoaderFlags</xsl:attribute>
				<xsl:value-of select="@NT_LoaderFlags" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NT_NumberOfRvaAndSizes</xsl:attribute>
				<xsl:value-of select="@NT_NumberOfRvaAndSizes" />
			</xsl:element>
			
			<xsl:apply-templates select="GrDoPESection" />
			
		</xsl:element>
	</xsl:template>	
	
</xsl:transform>