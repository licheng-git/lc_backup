//
//  SortAlgorithmVC.m
//  lcAhwTest
//
//  Created by licheng on 16/2/2.
//  Copyright © 2016年 lc. All rights reserved.
//

#import "SortAlgorithmVC.h"


////#define A  @[@7, @0, @5, @9, @1, @4 ,@2, @8, @6, @3]
//#define A  [[NSMutableArray alloc] initWithArray:@[@7, @0, @5, @9, @1, @4 ,@2, @8, @6, @3]]
//#define n  A.count


//int arr[] = {7, 0, 5, 9, 1, 4 , 2, 8, 6, 3, 2};
int arr[] = {50, 123, 543, 187, 49, 32, 0, 2, 11, 100, 32};
//#define n  (sizeof(arr) / sizeof(arr[0]))
int n = (sizeof(arr) / sizeof(arr[0]));

#define kLog  {\
  for (int i=0; i<n; i++)\
  {\
    NSLog(@"%d", arr[i]);\
  }\
}


//#define kXX(a,b,c)  { a++; c=a+b; }
//int a=1, b=5, c;
//kXX(a, b, c);
//NSLog(@"*_* %i", c);


@implementation SortAlgorithmVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    //int arr[10] = {7, 0, 5, 9, 1, 4 , 2, 8, 6, 3};
//    int arr[] = {7, 0, 5, 9, 1, 4 , 2, 8, 6, 3};
//    int arr_len = (sizeof(arr) / sizeof(arr[0]));
    
    //sort_bubble();        // *冒泡排序
    //sort_selection();     // *选择排序（简单选择排序）
    //sort_insertion();     // *插入排序（直接插入排序）
    //sort_quick_main();    // *_*快速排序
    //sort_heap();          // 堆排序
    //sort_shell();         // 希尔排序
    //sort_merge_main();    // 归并排序
    //sort_radix();         // 基数排序／桶排序
    kLog;
}

//内排序：
//交换排序 -> 冒泡排序，快速排序
//选择排序 -> 简单选择排序，堆排序
//插入排序 -> 直接插入排序，希尔排序
//归并排序
//基数排序／桶排序

//当n较大应采用时间复杂度为O(nlog2n)的排序方法：快速排序、堆排序、归并排序。
//快速排序是目前基于比较的内部排序中被认为是最好的方法，当待排序的关键字是随机分布时，快速排序的平均时间最短。



//稳定排序和非稳定排序
//stable sort：简单地说就是所有相等的数经过某种排序方法后，仍能保持它们在排序之前的相对次序；
//unstable sort：反之，就是非稳定的。
//
//内排序和外排序
//In-place sort：在排序过程中，所有需要排序的数都在内存，并在内存中调整它们的存储顺序；
//Out-place sort：在排序过程中，只有部分数被调入内存，并借助内存调整数在外存中的存放顺序排序方法。
//
//时间复杂度和空间复杂度
//时间复杂度，是指执行算法所需要的计算工作量。（最优／最差／平均）
//空间复杂度，一般是指执行这个算法所需要的内存空间。


void swap(int *a, int *b)
{
    int temp;
    temp = *a;
    *a = *b;
    *b = temp;
}


// 冒泡排序
// 算法思想：对当前还未排好序的范围内的全部数，自上而下对相邻的两个数依次进行比较和调整，让较大的数往下沉，较小的往上冒。
void sort_bubble()
{
    // 较大数往下沉
    for (int i=0; i<n; i++)
    {
        for (int j=0; j<n-1-i; j++)
        {
            if (arr[j] > arr[j+1])  // 相邻的两个数相比较
            {
                //int temp = arr[j];  arr[j] = arr[j+1];  arr[j+1] = temp;
                swap(&arr[j], &arr[j+1]);
            }
        }
    }
    
//    // 改进1：较大数往下沉同时较小数往上冒
//    int low = 0;
//    int high = n-1;
//    while (low < high)
//    {
//        for (int j=low; j<high; j++)  // 较大数往下沉
//        {
//            if (arr[j] > arr[j+1])
//            {
//                swap(&arr[j], &arr[j+1]);
//            }
//        }
//        high--;
//        
//        for (int j=high; j>low; j--)  // 较小数往上冒
//        {
//            if (arr[j] < arr[j-1])
//            {
//                swap(&arr[j], &arr[j-1]);
//            }
//        }
//        low++;
//    }
    
//    // 改进2：是否有数据交换；数据交换时下沉的位置
//
//    bool flag = true;  // 记录是否有数据交换，如果某一趟下去没有数据交换则i剩余接下来的就不需要比较了
//    for (int i=0; i<n && flag; i++)
//    {
//        flag = false;
//        for (int j=0; j<n-1-i; j++)
//        {
//            if (arr[j] > arr[j+1])
//            {
//                swap(&arr[j], &arr[j+1]);
//                flag = true;
//            }
//        }
//    }
//
//    int pos = 0;  // 记录数据交换的位置（下沉位置）
//    int i = n-1;
//    while (i>0)
//    {
//        pos = 0;
//        for (int j=0; j<i; j++)
//        {
//            if (arr[j] > arr[j+1])
//            {
//                swap(&arr[j], &arr[j+1]);
//                pos = j;  // 记录下沉位置
//            }
//        }
//        i = pos;  // 下一趟排序只需扫描到下沉位置处，pos位置之后的没有过数据交换即已经不需要比较了
//    }
}


// 选择排序（简单选择排序）
// 算法思想：选出最小的一个数与第一个位置的数交换；然后在剩下的数当中再找最小的与第二个位置的数交换，如此循环；即每次找一个最小值
// 二元选择排序，简单选择排序的改进，每次找出最大值和最小值两个
void sort_selection()
{
    int k = 0;
    for (int i=0; i<n; i++)
    {
        k = i;
        for (int j=i; j<n; j++)
        {
            if (arr[k] > arr[j])
            {
                k = j;
            }
        }
        if (k != i)
        {
            swap(&arr[i], &arr[k]);
        }
    }
}


// 插入排序（直接插入排序）
// 算法思想：假设前面n-1(n>=2)个数已经是排好顺序的，现在要把第n个数插到前面的有序数中，使得这n个数也是排好顺序的；如此反复直到全部排好顺序。
// *_* 打扑克，插牌
void sort_insertion()
{
//    for (int i=1; i<n; i++)
//    {
//        int key = arr[i];
//        int j= i-1;
//        while (j>=0 && arr[j]>key)
//        {
//            arr[j+1] = arr[j];
//            j--;
//        }
//        arr[j+1] = key;
//    }
    
    for (int i=1; i<n; i++)
    {
        //if (arr[i]<arr[i-1])
        {
            int key = arr[i];
            int j = 0;
            for (j=i-1; j>=0 && arr[j]>key; j--)
            {
                arr[j+1] = arr[j];
            }
            arr[j+1] = key;
        }
    }
    
//    for (int i=1; i<n; i++)
//    {
//        int key = arr[i];
//        int j = 0;  // 插入位置
//        for (int x=i-1; x>=0; x--)
//        {
//            if (arr[x] > key)
//            {
//                arr[x+1] = arr[x];
//            }
//            else
//            {
//                j = x+1;
//                break;
//            }
//        }
//        arr[j] = key;
//    }
}


// 快速排序
// 算法思想：通过一趟排序将要排序的数据分割成独立的两部分，其中一部分的所有数据都比另外一部分的所有数据都要小，然后再按此方法对这两部分数据分别进行快速排序，整个排序过程可以递归进行，以此达到整个数据变成有序序列。
// 冒泡排序的改进；公认最好；
// 快速排序改进：只对长度大于k的子序列递归调用快速排序，让原序列基本有序，然后再对整个基本有序序列用插入排序算法排序。实践证明，改进后的算法时间复杂度有所降低，且当k取值为 8 左右时，改进算法的性能最佳。
// if( high-low > k ) { 快排 }; 插排;
void sort_quick(int a[], int low, int high)
{
    if (low >= high)
    {
        return;
    }
    int first = low;
    int last = high;
    int key = a[first];  // 基准元素
    
    // 一分为二
    while (first < last)  // 从数组两端交替向中间扫描
    {
        while (first < last && a[last] >= key)  // 从high所指位置向前搜索，至多到low+1 位置。将比基准元素小的交换到低端
        {
            last--;
        }
        swap(&a[first], &a[last]);
        
        while (first < last && a[first] <= key)
        {
            first++;
        }
        swap(&a[first], &a[last]);
    }
    
    sort_quick(a, low, first-1);
    sort_quick(a, first+1, high);
}

void sort_quick_main()  // c语言面向过程不支持方法重载
{
    sort_quick(arr, 0, n-1);
    
    // c系统函数
    //qsort(arr, n, sizeof(arr[0]), cmp);  // 参数：1待排序数组首地址，2数组中待排序元素数量，3 各元素的占用空间大小，4指向函数的指针（一个比较函数，使排序更通用）。
}

int cmp(const void *a, const void *b)
{
    return *(int *)a - *(int *)b;
}


// 堆排序
// 算法思想：首先将待排序列构建为大顶堆（大顶堆：每个节点的值大于或等于其左右孩子节点的值）。此时整个序列的最大值就是堆顶的根节点，将它移走（就是将其与堆数组的末尾元素交换，此时末尾元素就是最大值），然后将剩余的n-1个子序列重新构造成一个堆，这样就会得到n个元素中的次大值，如此反复，便得到一个有序序列。
// 堆排序是一种树形选择排序，是对直接选择排序的有效改进
void HeapAdjust(int a[], int i, int len)  // 参数：1待调整的堆数组，2待调整的数组元素位置，3数组长度
{
//    int temp = a[i];
//    for (int j=i*2+1; j<len; j=j*2+1)
//    {
//        if (j+1<len && a[j]<a[j+1])
//        {
//            j++;
//        }
//        if (temp>a[j])
//        {
//            break;
//        }
//        a[i] = a[j];
//        i = j;
//    }
//    a[i] = temp;
    
    int temp = a[i];
    int child = 2*i+1;  // 左孩子节点的位置。（child+1为右孩子节点的位置）
    while (child < len)
    {
        if (child+1<len && a[child]<a[child+1])  // 找到较大的孩子节点
        {
            child++;
        }
        if (temp<a[child])  // 如果孩子节点大于父节点，则父子节点交换 较大的孩子往上移替换它的父节点
        {
            swap(&a[i], &a[child]);
            i = child;  // 为while下一次查找做准备
            child = 2*i+1;
        }
        else  // 父节点大于左右孩子节点，则不需要调整直接退出
        {
            break;
        }
    }
}
void sort_heap()
{
    for (int i=n/2-1; i>=0; i--)  // 初始化生成一个大顶堆数组。(n/2-1)是最后一个有孩子的节点的位置
    {
        HeapAdjust(arr, i, n);
    }
    for (int i=n-1; i>=1; i--)
    {
        swap(&arr[0], &arr[i]);
        HeapAdjust(arr, 0, i);
    }
}


// 希尔排序
// 算法思想：先将整个待排序记录序列分割成为若干子序列分别进行直接插入排序，使整个序列中的记录“基本有序”，最后对全体记录进行一次直接插入排序。
// 直接插入排序的改进，又叫缩小增量排序

//操作方法：
//1.选择一个增量序列t1，t2，…，tk，其中ti>tj，tk=1；（n/2,n/4,n/8,...,1）
//2.按增量序列个数k，对序列进行k趟排序；
//3.每趟排序，根据对应的增量ti，将待排序列分割成若干长度为m 的子序列，分别对各子表进行直接插入排序。仅增量因子为1 时，整个序列作为一个表来处理，表长度即为整个序列的长度。
//即：先将要排序的一组记录按某个增量d（n/2,n为要排序数的个数）分成若干组子序列，每组中记录的下标相差d.对每组中全部元素进行直接插入排序，然后再用一个较小的增量（d/2）对它进行分组，在每组中再进行直接插入排序。继续不断缩小增量直至为1，最后使用直接插入排序完成排序。
void sort_shell()
{
    int gap = n;
    while (gap >= 1)
    {
        gap = gap / 2;  // 减小增量，需保证最终等于1  （/向下取整）
        // 直接插入排序
        for (int i=gap; i<n; i++)
        {
            if (arr[i] < arr[i-gap])
            {
                int key = arr[i];
                int j=0;
                for (j=i-gap; j>=0&&arr[j]>key; j-=gap)
                {
                    arr[j+gap] = arr[j];
                }
                arr[j+gap] = key;
            }
        }
    }
    
//    int a=3,b=5;
//    int c = b/a;  // 向下取整
//    printf("*_* %i \n", c);
}


// 归并排序
// 算法思想：假设初始序列含有n个记录，则可以看成是n个有序的子序列，每个子序列的长度为1，然而两两归并，得到[n/2]（[x]表示不小于x的最小整数）个长度为2或1的有序子序列；再两两归并，如此反复，直至得到一个长度为n的有序序列。
void merge(int sourceArr[], int *tempArr, int startIndex, int midIndex, int endIndex)  // 将a[s,,,m]和a[m+1,,,e]归并到辅助数组t[s,,,e]
{
    int i=startIndex, j=midIndex+1, k=startIndex;
    while (i!=midIndex+1 && j!=endIndex+1)
    {
        if (sourceArr[i] >= sourceArr[j])
        {
            tempArr[k++] = sourceArr[j++];
        }
        else
        {
            tempArr[k++] = sourceArr[i++];
        }
    }
    while (i!=midIndex+1)
    {
        tempArr[k++] = sourceArr[i++];
    }
    while (j!=endIndex+1)
    {
        tempArr[k++] = sourceArr[j++];
    }
    
    for (i=startIndex; i<=endIndex; i++)
    {
        sourceArr[i] = tempArr[i];
    }
}

void sort_merge(int *sourceArr, int tempArr[], int startIndex, int endIndex)
{
    if (startIndex < endIndex)
    {
        int midIndex = (startIndex + endIndex) / 2;  // 平分数组a
        sort_merge(sourceArr, tempArr, startIndex, midIndex);  // 递归将a[s,,,m]归并为有序的a1[s,,,m]
        sort_merge(sourceArr, tempArr, midIndex+1, endIndex);  // 递归将a[m+1,,,e]归并为有序的a2[m+1,,,e]
        merge(sourceArr, tempArr, startIndex, midIndex, endIndex);  // 将有序的a1[s,,,m]和a2[m+1,,,e]归并到a[s,,,e]
    }
}

void sort_merge_main()
{
    int tempArr[n];
    sort_merge(arr, tempArr, 0, n-1);
}


// 基数排序／桶排序
// 算法思想：是将阵列分到有限数量的桶子里。每个桶子再个别排序（有可能再使用别的排序算法或是以递回方式继续使用桶排序进行排序）。简单来说，就是把数据分组，放在一个个的桶中，然后对每个桶里面的在进行排序。
/*
基数排序与本系列前面讲解的七种排序方法都不同，它不需要比较关键字的大小。它是根据关键字中各位的值，通过对排序的N个元素进行若干趟“分配”与“收集”来实现排序的。
举例：
设有一个初始序列为: R {50, 123, 543, 187, 49, 30, 0, 2, 11, 100}。
我们知道，任何一个阿拉伯数，它的各个位数上的基数都是以0~9来表示的。
所以我们不妨把0~9视为10个桶。
我们先根据序列的个位数的数字来进行分类，将其分到指定的桶中。例如：R[0] = 50，个位数上是0，将这个数存入编号为0的桶中。
 [0]  50, 30, 0, 100
 [1]  11
 [2]  2
 [3]  123, 253
 [4]
 [5]
 [6]
 [7]  187
 [8]
 [9]  49
分类后，我们在从各个桶中，将这些数按照从编号0到编号9的顺序依次将所有数取出来。
这时，得到的序列就是个位数上呈递增趋势的序列。
按照个位数排序： {50, 30, 0, 100, 11, 2, 123, 543, 187, 49}。
接下来，可以对十位数、百位数也按照这种方法进行排序，最后就能得到排序完成的序列。
*/
void sort_radix()
{
    int radix = 10;  // 基数
    int count[radix];  // 存放各个桶的数据统计个数
    int bucket[n];
    int i=0, j=0;
    int maxNum = find_max_num(arr);
    int digit = get_num_length(maxNum);
    for (int d=1; d<=digit; d++)  // 按照从低位到高位的顺序执行排序过程
    {
        for (i=0; i<radix; i++)  // 置空各个桶的数据统计
        {
            count[i] = 0;
        }
        for (i=0; i<n; i++)  // 统计各个桶将要装入的数据个数
        {
            j = get_digit(arr[i], d);
            count[j]++;
        }
        for (i=1; i<radix; i++)  // count[i]表示第i个桶的右边界索引
        {
            count[i] = count[i] + count[i-1];
        }
        for (i=n-1; i>=0; i--)  // 将数据依次装入桶中，这里要从右向左扫描，保证排序稳定性
        {
            j = get_digit(arr[i], d);  // 求出关键码的第d位的数字
            bucket[count[j]-1] = arr[i];  // 放入对应的桶中，count[j]-1是第j个桶的右边届索引
            count[j]--;  // 对应桶的装入数据索引减一
        }
        for (i=0,j=0; i<n; i++,j++)
        {
            arr[i] = bucket[j];
        }
    }
}

int get_digit(int num, int d)  // 获取num这个数d位数上的数字，例如获取123的1位数，结果返回3
{
    int x = pow(10, d-1);  // pow(double x, double y); x为底的y次方值
    return ((num / x) % 10);
}

int find_max_num(int *a)  // 查询数组中的最大值
{
    int len = (sizeof(a) / sizeof(a[0]));
    int max = 0;
    for (int i=0; i<len; i++)
    {
        if (*(a+i) > max)
        {
            max = *(a+i);
        }
    }
    return max;
}

int get_num_length(int num)  // 获取数字的最大位数，例如120是3
{
    int length = 1;
    int temp = num / 10;
    while (temp != 0)
    {
        length++;
        temp = temp / 10;
    }
    return length;
}


@end

