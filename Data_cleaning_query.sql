

-- /* Cleaning Data in SQL */

select * from Portfolio_Projects..Nashvilee_Housing;

---------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDateConverted, convert(Date, SaleDate)
from [Portfolio_Projects].[dbo].[Nashvilee_Housing]
order by 2 asc;



alter table Portfolio_Projects..Nashvilee_Housing
add SaleDateConverted Date;

Update Nashvilee_Housing
set SaleDateConverted = convert(Date, SaleDate);


---------------------------------------------------------------------------------------------------------------------------------

-- Populate Propert Address Data
select * 
from [Portfolio_Projects].[dbo].[Nashvilee_Housing]
-- where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from [Portfolio_Projects].[dbo].[Nashvilee_Housing] a
join [Portfolio_Projects].[dbo].[Nashvilee_Housing] b
	on a.ParcelID = b.ParcelID and
	a. [UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a 
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from [Portfolio_Projects].[dbo].[Nashvilee_Housing] a
join [Portfolio_Projects].[dbo].[Nashvilee_Housing] b
	on a.ParcelID = b.ParcelID and
	a. [UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from [Portfolio_Projects].[dbo].[Nashvilee_Housing] a
join [Portfolio_Projects].[dbo].[Nashvilee_Housing] b
	on a.ParcelID = b.ParcelID and
	a. [UniqueID ] <> b.[UniqueID ]


---------------------------------------------------------------------------------------------------------------------------------

-- Breaking Out Address into Individual columns (Address, City, State)

select PropertyAddress
from [Portfolio_Projects].[dbo].[Nashvilee_Housing]
-- where PropertyAddress is null
-- order by ParcelID

select 
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,  -- rid of comma
substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, len(PropertyAddress)) as Address
from [Portfolio_Projects].[dbo].[Nashvilee_Housing]


alter table Portfolio_Projects..Nashvilee_Housing
add PropertySplitAddress nvarchar(255);

Update Nashvilee_Housing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

alter table Portfolio_Projects..Nashvilee_Housing
add PropertySplitCity nvarchar(255);

Update Nashvilee_Housing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, len(PropertyAddress));

select * from [Portfolio_Projects].[dbo].[Nashvilee_Housing] 


select OwnerAddress from [Portfolio_Projects].[dbo].[Nashvilee_Housing]

select 
	PARSENAME(replace(OwnerAddress, ',', '.'), 3),
	PARSENAME(replace(OwnerAddress, ',', '.'), 2),
	PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from [Portfolio_Projects].[dbo].[Nashvilee_Housing]


alter table Portfolio_Projects..Nashvilee_Housing
add OwnerSplitAddress nvarchar(255);

Update Nashvilee_Housing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3);

alter table Portfolio_Projects..Nashvilee_Housing
add OwnerSplitCity nvarchar(255);

Update Nashvilee_Housing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2);

alter table Portfolio_Projects..Nashvilee_Housing
add OwnerSplitState nvarchar(255);

Update Nashvilee_Housing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1);

select * from [Portfolio_Projects].[dbo].[Nashvilee_Housing]


---------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select 
	distinct(SoldAsVacant), count(SoldAsVacant)
from Portfolio_Projects..Nashvilee_Housing
group by SoldAsVacant
order by 2

select
	SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
	end

from Portfolio_Projects..Nashvilee_Housing


Update Nashvilee_Housing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
				end


select 
	distinct(SoldAsVacant), count(SoldAsVacant)
from Portfolio_Projects..Nashvilee_Housing
group by SoldAsVacant
order by 2
	

---------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


with RowNumCTE as (
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate, 
				 LegalReference
				 order by uniqueid
				 ) row_num
from Portfolio_Projects..Nashvilee_Housing
-- order by ParcelID
)
select * from RowNumCTE
where row_num > 1
order by PropertyAddress


with RowNumCTE as (
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate, 
				 LegalReference
				 order by uniqueid
				 ) row_num
from Portfolio_Projects..Nashvilee_Housing
-- order by ParcelID
)
delete from RowNumCTE
where row_num > 1
-- order by PropertyAddress


select * from Portfolio_Projects..Nashvilee_Housing


---------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select 
	* 
from Portfolio_Projects..Nashvilee_Housing


alter table Portfolio_Projects..Nashvilee_Housing
drop column OwnerAddress,
			TaxDistrict,
			PropertyAddress

alter table Portfolio_Projects..Nashvilee_Housing
drop column SaleDate